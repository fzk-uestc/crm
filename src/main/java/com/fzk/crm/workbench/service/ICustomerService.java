package com.fzk.crm.workbench.service;

import com.fzk.crm.workbench.domain.Customer;

import java.util.List;

/**
 * @author fzkstart
 * @create 2021-03-14 15:39
 */
public interface ICustomerService {
    List<String> getCustomerNameList(String customerName);

    Customer getCustomerByName(String customerName);
}
