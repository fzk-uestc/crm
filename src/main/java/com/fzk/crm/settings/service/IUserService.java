package com.fzk.crm.settings.service;

import com.fzk.crm.exception.LoginException;
import com.fzk.crm.settings.domain.User;

import java.util.List;

/**
 * @author fzkstart
 * @create 2021-02-22 13:05
 */
public interface IUserService {
    User login(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> getUserList();
}
