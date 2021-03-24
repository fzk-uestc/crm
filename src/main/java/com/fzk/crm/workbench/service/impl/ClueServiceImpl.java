package com.fzk.crm.workbench.service.impl;

import com.fzk.crm.settings.dao.UserDao;
import com.fzk.crm.settings.domain.User;
import com.fzk.crm.utils.DateTimeUtil;
import com.fzk.crm.utils.SqlSessionUtil;
import com.fzk.crm.utils.UUIDUtil;
import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.dao.*;
import com.fzk.crm.workbench.domain.*;
import com.fzk.crm.workbench.service.IClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-03-07 11:35
 */
@Service(value = "clueService")
public class ClueServiceImpl implements IClueService {
    @Autowired
    private UserDao userDao;
    @Autowired
    private ActivityDao activityDao;

    //线索相关表
    @Autowired
    private ClueDao clueDao;
    @Autowired
    private ClueRemarkDao clueRemarkDao;
    @Autowired
    private ClueActivityRelationDao clueActivityRelationDao;

    //客户相关表
    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private CustomerRemarkDao customerRemarkDao;

    //联系人相关表
    @Autowired
    private ContactsDao contactsDao;
    @Autowired
    private ContactsRemarkDao contactsRemarkDao;
    @Autowired
    private ContactsActivityRelationDao contactsActivityRelationDao;

    //交易相关表
    @Autowired
    private TranDao tranDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;

    @Override
    public boolean saveClue(Clue clue) {
        int count = clueDao.saveClue(clue);
        return count == 1;
    }

    @Override
    public Clue detail(String clueId) {
        Clue clue = clueDao.getClueById(clueId);
        //此时查出来的owner是id形式的
        User user = userDao.getUserById(clue.getOwner());
        clue.setOwner(user.getName());
        return clue;
    }

    @Override
    public PaginationVO<Clue> pageList(Map<String, Object> map) {
        PaginationVO<Clue> vo = new PaginationVO();
        int total = clueDao.getTotalByCondition(map);
        List<Clue> dataList = clueDao.getClueListByCondition(map);
        vo.setTotal(total);
        vo.setDataList(dataList);
        return vo;
    }

    @Override
    public List<Activity> getActivityByClueId(String clueId) {
        return activityDao.getActivityByClueId(clueId);
    }

    @Override
    public boolean unbund(String relationId) {
        int count = clueActivityRelationDao.unbund(relationId);
        return count == 1;
    }

    @Override
    public List<Activity> getActivityByNameAndNotRelationClueId(Map<String, String> map) {
        return activityDao.getActivityByNameAndNotRelationClueId(map);
    }

    @Override
    public boolean bund(String clueId, String[] activityIds) {
        boolean flag = true;
        ClueActivityRelation relation = new ClueActivityRelation();
        for (String activityId : activityIds) {
            //为每条记录生成uuid
            String id = UUIDUtil.getUUID();
            relation.setId(id);
            relation.setClueId(clueId);
            relation.setActivityId(activityId);
            flag = (1 == clueActivityRelationDao.bund(relation));
        }
        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndClue(String clueId) {
        List<User> userList = userDao.getUserList();
        Clue clue = clueDao.getClueById(clueId);
        Map<String, Object> map = new HashMap<>();
        map.put("userList", userList);
        map.put("clue", clue);
        return map;
    }

    @Override
    public boolean updateClue(Clue clue) {
        return 1 == clueDao.updateClue(clue);
    }

    @Override
    public boolean deleteClueByIds(String[] ids) {
        boolean flag = true;
        //删除线索需要级联删除clue_remark和clue_activity_relation
        //记录删除掉的备注数量
        int remarkCount = clueRemarkDao.getCountByClueIds(ids);
        //删除备注
        if (remarkCount != 0) {
            flag = remarkCount == clueRemarkDao.deleteRemarkByClueIds(ids);
        }

        //记录删除的relation数
        int relationCount = clueActivityRelationDao.getCountByClueIds(ids);
        //删除clue_activity_relation
        if (relationCount != 0 && relationCount != clueActivityRelationDao.deleteRelationByClueIds(ids)) {
            flag = false;
        }
        //删除clue
        if (ids.length != clueDao.deleteClueByIds(ids)) {
            flag = false;
        }
        return flag;
    }

    @Override
    public List<Activity> getActivityListByName(String activityName) {
        return activityDao.getActivityListByName(activityName);
    }

    @Override
    public boolean convert(Tran tran, String clueId, String createBy) {
        boolean flag = true;
        String createTime = DateTimeUtil.getSysTime();
        /*
        (1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
        (2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
        (3) 通过线索对象提取联系人信息，保存联系人
        (4) 线索备注转换到客户备注以及联系人备注
        (5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
        (6) 如果有创建交易需求，创建一条交易
        (7) 如果创建了交易，则创建一条该交易下的交易历史
        (8) 删除线索备注
        (9) 删除线索和市场活动的关系
        (10) 删除线索
         */
        //(1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
        Clue clue = clueDao.getClueById(clueId);
        //(2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
        String company = clue.getCompany();
        Customer customer = customerDao.getCustomerByName(company);
        if (customer == null) {
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setCreateTime(createTime);
            customer.setCreateBy(createBy);
            //从clue中获取的信息
            customer.setAddress(clue.getAddress());
            customer.setWebsite(clue.getWebsite());
            customer.setContactSummary(clue.getContactSummary());
            customer.setDescription(clue.getDescription());
            customer.setName(company);
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setOwner(clue.getOwner());
            customer.setPhone(clue.getPhone());

            //添加客户
            flag = 1 == customerDao.saveCustomer(customer);
        }
        //(3) 通过线索对象提取联系人信息，保存联系人
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setCreateTime(createTime);
        contacts.setCreateBy(createBy);
        //从clue中获取的信息
        contacts.setAddress(clue.getAddress());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setDescription(clue.getDescription());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setOwner(clue.getOwner());
        contacts.setJob(clue.getJob());
        contacts.setAppellation(clue.getAppellation());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setSource(clue.getSource());
        contacts.setFullname(clue.getFullname());
        //从客户中获取信息
        contacts.setCustomerId(customer.getId());
        flag = (1 == contactsDao.saveContacts(contacts)) && flag;

        //(4) 线索备注转换到客户备注以及联系人备注
        List<ClueRemark> clueRemarkList = clueRemarkDao.getRemarkListByClueId(clueId);
        for (ClueRemark clueRemark : clueRemarkList) {
            //取出每一条线索的备注信息
            String noteContent = clueRemark.getNoteContent();
            //客户备注
            CustomerRemark customerRemark = new CustomerRemark();
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setCreateTime(createTime);
            customerRemark.setCreateBy(createBy);
            customerRemark.setNoteContent(noteContent);
            customerRemark.setCustomerId(customer.getId());
            customerRemark.setEditFlag("0");
            flag = (1 == customerRemarkDao.saveRemark(customerRemark)) && flag;
            //联系人备注
            ContactsRemark contactsRemark = new ContactsRemark();
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setNoteContent(noteContent);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setEditFlag("0");
            contactsRemark.setContactsId(contacts.getId());
            flag = (1 == contactsRemarkDao.saveRemark(contactsRemark)) && flag;
        }

        //(5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getRelationListByClueId(clueId);
        for (ClueActivityRelation clueActivityRelation : clueActivityRelationList) {
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setContactsId(contacts.getId());
            contactsActivityRelation.setActivityId(clueActivityRelation.getActivityId());
            flag = (1 == contactsActivityRelationDao.bind(contactsActivityRelation)) && flag;
        }

        //(6) 如果有创建交易需求，创建一条交易
        if (tran != null) {
            /*
            tran对象在controller中已经封装了如下信息：
            id,createTime,createBy,money,name,expectedDate,stage,activityId

            接下来继续从其他对象中取出信息封装到tran中
             */
            tran.setContactsId(contacts.getId());
            tran.setContactSummary(contacts.getContactSummary());
            tran.setCustomerId(customer.getId());
            tran.setSource(clue.getSource());
            tran.setOwner(clue.getOwner());
            tran.setNextContactTime(clue.getNextContactTime());
            tran.setDescription(clue.getDescription());
            flag = (1 == tranDao.saveTran(tran)) && flag;


            //(7) 如果创建了交易，则创建一条该交易下的交易历史
            TranHistory tranHistory = new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setTranId(tran.getId());
            tranHistory.setStage(tran.getStage());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            flag = (1 == tranHistoryDao.saveTranHistory(tranHistory)) && flag;
        }
        /*
        (8) 删除线索备注
        (9) 删除线索和市场活动的关系
        (10) 删除线索
        这里调用之前写过的一个删除clue的service方法，里面包含有级联删除clueRemark和clue_activity_relation
        */
        flag = deleteClueByIds(new String[]{clueId}) && flag;
        return flag;
    }

    @Override
    public Map<String, Object> getCharts() {
        /*
        data
            {"total":10,"dataList":[{value: 60, name: '访问'},{},...]}
        */
        int total = clueDao.getTotal();
        List<Map<String, Object>> dataList = clueDao.getCharts();
        Map<String, Object> map = new HashMap<>();
        map.put("total", total);
        map.put("dataList", dataList);
        return map;
    }

    @Override
    public List<ClueRemark> getRemarkListByClueId(String clueId) {
        return clueRemarkDao.getRemarkListByClueId(clueId);
    }
}
