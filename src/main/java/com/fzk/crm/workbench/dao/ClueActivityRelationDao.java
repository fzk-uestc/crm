package com.fzk.crm.workbench.dao;


import com.fzk.crm.workbench.domain.ClueActivityRelation;

import java.util.List;
import java.util.Map;

public interface ClueActivityRelationDao {


    int unbund(String relationId);

    int bund(ClueActivityRelation relation);

    int getCountByClueIds(String[] ids);

    int deleteRelationByClueIds(String[] ids);

    List<ClueActivityRelation> getRelationListByClueId(String clueId);
}
