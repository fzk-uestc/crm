package com.fzk.crm.settings.dao;

import com.fzk.crm.settings.domain.User;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-02-22 13:02
 */
public interface UserDao {
    User login(Map<String,String> map);

    List<User> getUserList();

    User getUserById(String id);

}
