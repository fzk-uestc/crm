package com.fzk.crm.workbench.service;

import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.domain.Activity;

import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-25 12:58
 */
public interface IActivityService {
    boolean saveActivity(Activity activity);

    PaginationVO<Activity> pageList(Map<String, Object> map);

    boolean deleteActivity(String[] ids);
}
