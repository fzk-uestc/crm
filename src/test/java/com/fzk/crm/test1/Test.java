package com.fzk.crm.test1;

import com.fzk.crm.utils.DateTimeUtil;
import com.fzk.crm.utils.MD5Util;

/**
 * @author fzkstart
 * @create 2021-02-23 19:48
 */
public class Test {
    public static void main(String[] args) {
        //验证失效时间
        //失效时间是这个
        String expireTime = "2021-02-23 19:49:10";

        //当前系统时间
        String currentTime = DateTimeUtil.getSysTime();

        if(currentTime.compareTo(expireTime)>0){
            System.out.println("失效啦！");
        }else{
            System.out.println("没有失效啦！");
        }

        String lockState=new String("0");
        if("0".equals(lockState)){
            System.out.println("锁定了！");
        }

        String pwd="12w3Y4Yz5";
        String md5 = MD5Util.getMD5(pwd);
        System.out.println(md5);

    }
}
