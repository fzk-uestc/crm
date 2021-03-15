package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    int getCountByClueIds(String[] ids);

    int deleteRemarkByClueIds(String[] ids);

    List<ClueRemark> getRemarkListByClueId(String clueId);
}
