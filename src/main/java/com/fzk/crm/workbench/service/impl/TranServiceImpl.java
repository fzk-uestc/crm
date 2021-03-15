package com.fzk.crm.workbench.service.impl;

import com.fzk.crm.utils.SqlSessionUtil;
import com.fzk.crm.utils.UUIDUtil;
import com.fzk.crm.workbench.dao.*;
import com.fzk.crm.workbench.domain.*;
import com.fzk.crm.workbench.service.ITranService;

import java.util.List;
import java.util.UUID;

/**
 * @author fzkstart
 * @create 2021-03-14 12:35
 */
public class TranServiceImpl implements ITranService {
    //交易dao
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    //市场活动dao
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    //联系人dao
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    //客户dao
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    @Override
    public List<Activity> getActivityListByName(String activityName) {
        return activityDao.getActivityListByName(activityName);
    }

    @Override
    public List<Contacts> getContactsListByName(String contactsName) {
        return contactsDao.getContactsListByName(contactsName);
    }

    @Override
    public boolean saveTran(Tran tran, String customerName) {
        boolean flag = true;
        /*
        1.保存tran需要先判断客户是否已经存在，如果不存在则需要新建
        2.取出customer的id赋给tran之后，保存tran
        3.然后新建并保存一条交易历史
         */
        Customer customer = customerDao.getCustomerByName(customerName);
        if (customer == null) {
            //客户不存在，需要创建新客户
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(tran.getOwner());
            customer.setName(customerName);
            customer.setCreateBy(tran.getCreateBy());
            customer.setCreateTime(tran.getCreateTime());
            customer.setContactSummary(tran.getContactSummary());
            customer.setNextContactTime(tran.getNextContactTime());
            customer.setDescription(tran.getDescription());
            //调用持久层保存
            customerDao.saveCustomer(customer);
        }
        //取出customerId赋值给tran
        tran.setCustomerId(customer.getId());
        //保存tran
        flag = 1 == tranDao.saveTran(tran);

        //新建tranHistory
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setTranId(tran.getId());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setStage(tran.getStage());
        tranHistory.setCreateTime(tran.getCreateTime());
        tranHistory.setCreateBy(tran.getCreateBy());
        //保存tranHistory
        flag = (1 == tranHistoryDao.saveTranHistory(tranHistory)) && flag;

        return flag;
    }

    @Override
    public Tran detail(String tranId) {
        return tranDao.getTranDetailById(tranId);
    }

    @Override
    public List<TranHistory> getTranHistoryListByTranId(String tranId) {
        return tranHistoryDao.getTranHistoryListByTranId(tranId);
    }

    @Override
    public boolean changeStage(Tran tran) {
        boolean flag = true;
        //改变交易阶段
        flag = 1 == tranDao.changeStage(tran);
        //生成新的交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setTranId(tran.getId());
        tranHistory.setCreateBy(tran.getEditBy());
        tranHistory.setCreateTime(tran.getEditTime());
        tranHistory.setStage(tran.getStage());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setMoney(tran.getMoney());
        flag = (1 == tranHistoryDao.saveTranHistory(tranHistory)) && flag;
        return flag;
    }
}
