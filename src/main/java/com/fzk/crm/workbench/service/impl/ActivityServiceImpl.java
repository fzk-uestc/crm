package com.fzk.crm.workbench.service.impl;

import com.fzk.crm.settings.dao.UserDao;
import com.fzk.crm.settings.domain.User;
import com.fzk.crm.utils.SqlSessionUtil;
import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.dao.ActivityDao;
import com.fzk.crm.workbench.dao.ActivityRemarkDao;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.domain.ActivityRemark;
import com.fzk.crm.workbench.service.IActivityService;
import org.apache.ibatis.session.SqlSessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-25 12:59
 */
@Service(value="activityService")
public class ActivityServiceImpl implements IActivityService {
    @Autowired
    private ActivityDao activityDao;
    @Autowired
    private ActivityRemarkDao activityRemarkDao;
    @Autowired
    private UserDao userDao;

    @Override
    public boolean saveActivity(Activity activity) {
        int count = activityDao.saveActivity(activity);
        return count == 1;
    }

    @Override
    public PaginationVO<Activity> pageList(Map<String, Object> map) {
        //取得total
        int total = activityDao.getTotalByCondition(map);
        //取得dataList
        List<Activity> dataList = activityDao.getActivityListByCondition(map);
        //将total和dataList封装到VO中
        PaginationVO<Activity> vo = new PaginationVO<>();
        vo.setTotal(total);
        vo.setDataList(dataList);
        //返回vo
        return vo;
    }

    @Override
    public boolean deleteActivity(String[] ids) {
        boolean flag = true;
        //查询出需要删除的备注的数量
        int count1 = activityRemarkDao.getCountByAids(ids);

        //删除备注，返回受影响的条数(实际删除的数量)
        int count2 = activityRemarkDao.deleteByAids(ids);
        if (count1 != count2) {
            flag = false;
        }
        //删除市场活动
        int count3 = activityDao.deleteActivity(ids);
        System.out.println("count1=" + count1 + ";count2=" + count2 + ";count3=" + count3 + ";ids.length=" + ids.length);
        if (count3 != ids.length) {
            flag = false;
        }
        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndActivity(String activityId) {
        //取userList
        List<User> userList = userDao.getUserList();
        //取activity
        Activity activity=activityDao.getActivityById(activityId);
        //打包为map
        Map<String, Object> map = new HashMap<>();
        map.put("userList",userList);
        map.put("activity",activity);
        //返回map
        return map;
    }

    @Override
    public boolean updateActivity(Activity activity) {
        int count = activityDao.updateActivity(activity);
        return count == 1;
    }

    @Override
    public Activity detail(String activityId) {
        Activity activity = activityDao.getActivityById(activityId);
        //但是此时的activity中的owner是id形式的
        //查出user后把name设置到activity.owner
        User user=userDao.getUserById(activity.getOwner());
        activity.setOwner(user.getName());
        return activity;
    }

    @Override
    public List<ActivityRemark> getRemarkListByActivityId(String activityId) {
        return activityRemarkDao.getRemarkListByActivityId(activityId);
    }

    @Override
    public boolean deleteRemark(String remarkId) {
        int count=activityRemarkDao.deleteRemarkById(remarkId);
        return count==1;
    }

    @Override
    public boolean saveRemark(ActivityRemark activityRemark) {
        int count=activityRemarkDao.saveRemark(activityRemark);
        return count==1;
    }

    @Override
    public boolean updateRemark(ActivityRemark activityRemark) {
        int count=activityRemarkDao.updateRemark(activityRemark);
        return count==1;
    }

    @Override
    public Map<String, Object> getCharts() {
        /*
        data
        {"total":10,"dataList":[{value: 60, name: '访问'},{},...]}
        */
        //取得total
        int total=activityDao.getTotal();
        //取得dataList
        List<Map<String,Object>> dataList=activityDao.getCharts();
        //将total和dataList保存到map
        Map<String,Object> map=new HashMap<>();
        map.put("total",total);
        map.put("dataList",dataList);
        //返回map
        return map;
    }
}
