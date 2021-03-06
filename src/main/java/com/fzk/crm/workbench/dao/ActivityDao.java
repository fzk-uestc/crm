package com.fzk.crm.workbench.dao;

import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.domain.Activity;
import org.apache.ibatis.annotations.Insert;

import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-25 12:53
 */
public interface ActivityDao {
    int saveActivity(Activity activity);

    int getTotalByCondition(Map<String, Object> map);

    List<Activity> getActivityListByCondition(Map<String, Object> map);

    int deleteActivity(String[] ids);

    Activity getActivityById(String activityId);

    int updateActivity(Activity activity);
}
