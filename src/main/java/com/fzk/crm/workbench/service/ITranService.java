package com.fzk.crm.workbench.service;

import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.domain.Contacts;
import com.fzk.crm.workbench.domain.Tran;
import com.fzk.crm.workbench.domain.TranHistory;

import java.util.List;

/**
 * @author fzkstart
 * @create 2021-03-14 12:35
 */
public interface ITranService {
    List<Activity> getActivityListByName(String activityName);

    List<Contacts> getContactsListByName(String contactsName);

    boolean saveTran(Tran tran,String customerName);

    Tran detail(String tranId);

    List<TranHistory> getTranHistoryListByTranId(String tranId);

    boolean changeStage(Tran tran);
}
