package com.fzk.crm.settings.domain;

/**
 * @author fzkstart
 * @create 2021-02-22 12:53
 */
public class User {
    /*
    关于字符串中表现的日期和时间
    市场上常用的有两种方式
    日期：年月日
        yyyy-MM-dd 10位字符串
    日期+时间：年月日分时秒 19位字符串
        yyyy-MM-dd HH:mm:ss
     */

    /*
    关于登录：
        验证账号和密码
        User user select * from tbl_user where loginAct=? and loginPsw=?;
        user==null;说明账户密码错误
        否则继续向下验证其他字段信息
            expireTime 验证失效时间
            lockState 0:锁定；1：开放
            allowIps 验证浏览器端的ip地址是否有效

     */
    private String id;  //编号  主键
    private String loginAct;    // 登录账号
    private String name;//用户真实姓名
    private String loginPsw;//登录密码
    private String email;//邮箱

    private String expireTime;//失效时间
    private String lockState;//锁定状态;锁定状态为空时表示启用，为0时表示锁定，为1时表示启用。
    private String deptno;//部门编号
    //允许访问的IP为空时表示IP地址永不受限，
    // 允许访问的IP可以是一个，也可以是多个，
    // 当多个IP地址的时候，采用半角逗号分隔。
    // 允许IP是192.168.100.2，
    // 表示该用户只能在IP地址为192.168.100.2的机器上使用。
    private String allowIps;
    private String createTime;//创建时间
    private String createBy;//创建人
    private String editTime;//修改时间
    private String editBy;//修改人

    public String getExpireTime() {
        return expireTime;
    }

    public void setExpireTime(String expireTime) {
        this.expireTime = expireTime;
    }

    public String getLockState() {
        return lockState;
    }

    public void setLockState(String lockState) {
        this.lockState = lockState;
    }

    public String getDeptno() {
        return deptno;
    }

    public void setDeptno(String deptno) {
        this.deptno = deptno;
    }

    public String getAllowIps() {
        return allowIps;
    }

    public void setAllowIps(String allowIps) {
        this.allowIps = allowIps;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLoginAct() {
        return loginAct;
    }

    public void setLoginAct(String loginAct) {
        this.loginAct = loginAct;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLoginPsw() {
        return loginPsw;
    }

    public void setLoginPsw(String loginPsw) {
        this.loginPsw = loginPsw;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getCreateBy() {
        return createBy;
    }

    public void setCreateBy(String createBy) {
        this.createBy = createBy;
    }

    public String getEditTime() {
        return editTime;
    }

    public void setEditTime(String editTime) {
        this.editTime = editTime;
    }

    public String getEditBy() {
        return editBy;
    }

    public void setEditBy(String editBy) {
        this.editBy = editBy;
    }

    @Override
    public String toString() {
        return "User{" +
                "id='" + id + '\'' +
                ", loginAct='" + loginAct + '\'' +
                ", name='" + name + '\'' +
                ", loginPsw='" + loginPsw + '\'' +
                ", email='" + email + '\'' +
                ", expireTime='" + expireTime + '\'' +
                ", lockState='" + lockState + '\'' +
                ", deptno='" + deptno + '\'' +
                ", allowIps='" + allowIps + '\'' +
                ", createTime='" + createTime + '\'' +
                ", createBy='" + createBy + '\'' +
                ", editTime='" + editTime + '\'' +
                ", editBy='" + editBy + '\'' +
                '}';
    }
}
