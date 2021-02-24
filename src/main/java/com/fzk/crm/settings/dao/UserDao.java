package com.fzk.crm.settings.dao;

import com.fzk.crm.settings.domain.User;

import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-22 13:02
 */
public interface UserDao {
    User login(Map<String,String> map);
}
