package com.fzk.crm.settings.service;

import com.fzk.crm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-03-07 11:53
 */
public interface IDicService {
    Map<String, List<DicValue>> getAll();
}

