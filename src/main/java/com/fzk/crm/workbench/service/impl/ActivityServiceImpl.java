package com.fzk.crm.workbench.service.impl;

import com.fzk.crm.utils.SqlSessionUtil;
import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.dao.ActivityDao;
import com.fzk.crm.workbench.dao.ActivityRemarkDao;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.domain.ActivityRemark;
import com.fzk.crm.workbench.service.IActivityService;

import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-25 12:59
 */
public class ActivityServiceImpl implements IActivityService {
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);

    @Override
    public boolean saveActivity(Activity activity) {
        System.out.println("进入到业务层saveActivity()...");
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
        System.out.println("count1="+count1+";count2="+ count2+";count3="+count3+";ids.length="+ids.length);
        if(count3!= ids.length){
            flag=false;
        }
        return flag;
    }
}
