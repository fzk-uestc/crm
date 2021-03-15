package com.fzk.crm.settings.dao;

import com.fzk.crm.settings.domain.DicValue;

import java.util.List;

/**
 * @author fzkstart
 * @create 2021-03-07 11:50
 */
public interface DicValueDao {
    List<DicValue> getValueByCode(String code);
}
