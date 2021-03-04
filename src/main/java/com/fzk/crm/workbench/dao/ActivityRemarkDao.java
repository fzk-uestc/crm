package com.fzk.crm.workbench.dao;

/**
 * @author fzkstart
 * @create 2021-03-01 17:51
 */
public interface ActivityRemarkDao {
    int getCountByAids(String[] ids);

    int deleteByAids(String[] ids);
}
