package com.fzk.crm.workbench.dao;


import com.fzk.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {
    int saveClue(Clue clue);

    Clue getClueById(String id);

    List<Clue> getClueListByCondition(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    int updateClue(Clue clue);

    int deleteClueByIds(String[] ids);

    int getTotal();

    List<Map<String, Object>> getCharts();
}
