package com.fzk.crm.workbench.service;

import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.domain.Clue;
import com.fzk.crm.workbench.domain.ClueRemark;
import com.fzk.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-03-07 11:35
 */
public interface IClueService {
    boolean saveClue(Clue clue);

    Clue detail(String clueId);

    PaginationVO<Clue> pageList(Map<String, Object> map);

    List<Activity> getActivityByClueId(String clueId);

    boolean unbund(String relationId);

    List<Activity> getActivityByNameAndNotRelationClueId(Map<String,String> map);

    boolean bund(String clueId, String[] activityIds);

    Map<String, Object> getUserListAndClue(String clueId);

    boolean updateClue(Clue clue);

    boolean deleteClueByIds(String[] ids);

    List<Activity> getActivityListByName(String activityName);

    boolean convert(Tran tran, String clueId,String createBy);

    Map<String, Object> getCharts();

    List<ClueRemark> getRemarkListByClueId(String clueId);
}
