package com.fzk.crm.vo;

import java.util.List;

/**
 * @author fzkstart
 * @create 2021-03-03 20:07
 */
public class PaginationVO<T>{
    private int total;
    private List<T> dataList;

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public List<T> getDataList() {
        return dataList;
    }

    public void setDataList(List<T> dataList) {
        this.dataList = dataList;
    }

    @Override
    public String toString() {
        return "PaginationVO{" +
                "total=" + total +
                ", dataList=" + dataList +
                '}';
    }
}
