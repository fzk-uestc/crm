package com.fzk.crm.workbench.service.impl;

import com.fzk.crm.utils.SqlSessionUtil;
import com.fzk.crm.workbench.dao.CustomerDao;
import com.fzk.crm.workbench.dao.CustomerRemarkDao;
import com.fzk.crm.workbench.domain.Customer;
import com.fzk.crm.workbench.service.ICustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author fzkstart
 * @create 2021-03-14 15:39
 */
@Service(value = "customerService")
public class CustomerServiceImpl implements ICustomerService {
    //客户dao
//    private CustomerDao customerDao= SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
//    private CustomerRemarkDao customerRemarkDao=SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);
    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private CustomerRemarkDao customerRemarkDao;

    @Override
    public List<String> getCustomerNameList(String customerName) {
        return customerDao.getCustomerNameList(customerName);
    }

    @Override
    public Customer getCustomerByName(String customerName) {
        return customerDao.getCustomerByName(customerName);
    }
}
