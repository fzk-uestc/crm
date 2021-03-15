package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {

    int saveTranHistory(TranHistory tranHistory);

    List<TranHistory> getTranHistoryListByTranId(String tranId);
}
