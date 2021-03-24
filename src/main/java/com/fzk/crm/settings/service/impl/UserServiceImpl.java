package com.fzk.crm.settings.service.impl;

import com.fzk.crm.exception.LoginException;
import com.fzk.crm.settings.dao.UserDao;
import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.utils.DateTimeUtil;
import com.fzk.crm.utils.SqlSessionUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-22 13:06
 */
@Service(value = "userService")
public class UserServiceImpl implements IUserService {
    @Autowired
    private UserDao userDao;

    public User login(String loginAct, String loginPwd, String ip) throws LoginException {

        System.out.println("进入到业务层login方法");

        Map<String, String> map = new HashMap<>();
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);

        User user = userDao.login(map);

        if (user == null) {
            throw new LoginException("123账户密码错误");
        }
        //账户密码正确，继续向下验证其他三项信息
        //验证失效时间expireTime
        String currentTime = DateTimeUtil.getSysTime();
        if (currentTime.compareTo(user.getExpireTime()) > 0) {
            throw new LoginException("账号已经失效");
        }

        //判定锁定状态lockState
        String lockState = user.getLockState();
        if ("0".equals(lockState)) {
            throw new LoginException("账号已锁定");
        }

        //判断ip地址
        String allowIps = user.getAllowIps();
        if (allowIps == null || "".equals(allowIps)) {
            //说明没有对访问的ip地址设置限制
        } else if (!allowIps.contains(ip)) {
            throw new LoginException("此ip地址不允许访问");
        }
        return user;
    }

    @Override
    public List<User> getUserList() {
        return userDao.getUserList();
    }

}
