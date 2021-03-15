package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.Tran;

public interface TranDao {

    int saveTran(Tran tran);

    Tran getTranDetailById(String tranId);

    int changeStage(Tran tran);
}
