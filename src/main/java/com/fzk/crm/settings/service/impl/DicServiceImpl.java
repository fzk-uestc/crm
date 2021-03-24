package com.fzk.crm.settings.service.impl;

import com.fzk.crm.settings.dao.DicTypeDao;
import com.fzk.crm.settings.dao.DicValueDao;
import com.fzk.crm.settings.domain.DicType;
import com.fzk.crm.settings.domain.DicValue;
import com.fzk.crm.settings.service.IDicService;
import com.fzk.crm.utils.SqlSessionUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author fzkstart
 * @create 2021-03-07 11:53
 */
public class DicServiceImpl implements IDicService {
    private DicTypeDao dicTypeDao= SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dicValueDao= SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    @Override
    public Map<String, List<DicValue>> getAll() {
        Map<String,List<DicValue>> map=new HashMap<>();
        //查出所有字典类型
        List<DicType> dicTypeList=dicTypeDao.getTypeList();
        //根据字典类型的code查询出DicValue
        for(DicType dicType:dicTypeList){
            List<DicValue> dicValueList=
                    dicValueDao.getValueByCode(dicType.getCode());
            //封装到map
            map.put(dicType.getCode(),dicValueList);
        }
        return map;
    }
}
