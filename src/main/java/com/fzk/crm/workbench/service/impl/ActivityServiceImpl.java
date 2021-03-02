package com.fzk.crm.workbench.service.impl;

import com.fzk.crm.utils.SqlSessionUtil;
import com.fzk.crm.workbench.dao.ActivityDao;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.service.IActivityService;

/**
 * @author fzkstart
 * @create 2021-02-25 12:59
 */
public class ActivityServiceImpl implements IActivityService {
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    @Override
    public boolean saveActivity(Activity activity) {
        System.out.println("进入到业务层saveActivity()...");
        int count=activityDao.saveActivity(activity);
        return count == 1;
    }
}
