<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script>
        //登录的验证方法
        function login() {
            //验证账号和密码格式合法
            let loginAct = $("#loginAct").val();
            let loginPwd = $("#loginPwd").val();
            //正则表达式
            let loginActPt = /^[a-z0-9_-]{2,16}$/;
            let loginPwdPt = /^[a-z0-9_-]{3,18}$/;
            if (!loginActPt.test(loginAct)) {
                $("#msg").text("用户名不合法！");
            } else if (!loginPwdPt.test(loginPwd)) {
                $("#msg").text("密码不合法！");
            } else {
                //清空提示框
                $("#msg").text("");

                //发送ajax请求
                $.ajax({
                    url: "settings/user/login.do",
                    data: {
                        "loginAct": loginAct,
                        "loginPwd": loginPwd
                    },
                    type: "post",
                    dataType: "json",
                    success: function (message) {
                        /*
                        message
                            {"success":true/false,"msg":"哪里出错了"}
                         */
                        //登录成功，跳转到工作台欢迎页
                        if (message.success === true) {
                            window.location.href = "workbench/index.jsp";
                        } else {
                            $("#msg").html(message.msg);
                        }
                    }
                });
            }
        }

        $(function () {
            //使login.jsp始终在顶层窗口中打开
            if(window.top!=window){
                window.top.location=window.location;
            }

            //页面加载完成后，用户文本框自动获取焦点
            $("#loginAct").focus();

            //绑定登录按钮
            $(".btn-lg").click(function () {
                login();
                return false;
            });
        });
    </script>
</head>
<body>

<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
    <img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
</div>
<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
    <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">
        CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
</div>

<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
    <div style="position: absolute; top: 0px; right: 60px;">
        <div class="page-header">
            <h1>登录</h1>
        </div>
        <form action="workbench/index.jsp" class="form-horizontal" role="form">
            <div class="form-group form-group-lg">
                <div style="width: 350px;">
                    <input class="form-control" type="text" placeholder="用户名" id="loginAct">
                </div>
                <div style="width: 350px; position: relative;top: 20px;">
                    <input class="form-control" type="password" placeholder="密码" id="loginPwd">
                </div>
                <div class="checkbox" style="position: relative;top: 30px; left: 10px;">

                    <span id="msg"></span>

                </div>
                <button type="submit" class="btn btn-primary btn-lg btn-block"
                        style="width: 350px; position: relative;top: 45px;">登录
                </button>
            </div>
        </form>
    </div>
</div>


</body>
</html>