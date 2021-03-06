package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.ActivityRemark;

import java.util.List;

/**
 * @author fzkstart
 * @create 2021-03-01 17:51
 */
public interface ActivityRemarkDao {
    int getCountByAids(String[] ids);

    int deleteByAids(String[] ids);

    List<ActivityRemark> getRemarkListByActivityId(String activityId);

    int deleteRemarkById(String remarkId);

    int saveRemark(ActivityRemark activityRemark);

    int updateRemark(ActivityRemark activityRemark);
}
