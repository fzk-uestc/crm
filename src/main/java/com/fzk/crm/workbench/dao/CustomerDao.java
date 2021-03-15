package com.fzk.crm.workbench.dao;

import com.fzk.crm.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    Customer getCustomerByName(String customerName);

    int saveCustomer(Customer customer);

    List<String> getCustomerNameList(String customerName);
}
