package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.Activity;
import org.apache.ibatis.annotations.Insert;

/**
 * @author fzkstart
 * @create 2021-02-25 12:53
 */
public interface ActivityDao {
    @Insert("insert into tbl_activity(id, owner, name, startDate, endDate, cost, description, createTime, createBy)"
            +"values(#{id},#{owner},#{name},#{startDate},#{endDate},#{cost},#{description},#{createTime},#{createBy})")
    int saveActivity(Activity activity);
}
