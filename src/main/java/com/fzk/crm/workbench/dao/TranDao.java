package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int saveTran(Tran tran);

    Tran getTranDetailById(String tranId);

    int changeStage(Tran tran);

    List<Tran> getTranListByCondition(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    int getTotal();

    List<Map<String, Object>> getCharts();
}
