package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.Contacts;

import java.util.List;

public interface ContactsDao {

    int saveContacts(Contacts contacts);

    List<Contacts> getContactsListByName(String contactsName);
}
