package com.fzk.crm.workbench.service;

import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-25 12:58
 */
public interface IActivityService {
    boolean saveActivity(Activity activity);

    PaginationVO<Activity> pageList(Map<String, Object> map);

    boolean deleteActivity(String[] ids);

    Map<String, Object> getUserListAndActivity(String activityId);

    boolean updateActivity(Activity activity);

    Activity detail(String activityId);

    List<ActivityRemark> getRemarkListByActivityId(String activityId);

    boolean deleteRemark(String remarkId);

    boolean saveRemark(ActivityRemark activityRemark);

    boolean updateRemark(ActivityRemark activityRemark);
}

