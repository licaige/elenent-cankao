<template>
  <div class="fillcontain">
    <head-top></head-top>
    <div class="table_container">
      <!-- 表格 -->
      <el-table :data="tableData" highlight-current-row style="width: 100%">
        <el-table-column type="index" width="100">
        </el-table-column>
        <!-- property: 同prop -->
        <el-table-column property="registe_time" label="注册日期" width="220">
        </el-table-column>
        <el-table-column property="username" label="用户姓名" width="220">
        </el-table-column>
        <el-table-column property="city" label="注册地址">
        </el-table-column>
      </el-table>
      <!-- 页码块 -->
      <div class="Pagination" style="text-align: left;margin-top: 10px;">
        <el-pagination @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page="currentPage" :page-size="20" layout="total, prev, pager, next" :total="count">
        </el-pagination>
      </div>
    </div>
  </div>
</template>

<script>
import headTop from '../components/headTop'
import { getUserList, getUserCount } from '@/api/getData'
export default {
  data() {
    return {
      tableData: [{
        registe_time: '2016-05-02',
        username: '王小虎',
        city: '上海市普陀区金沙江路 1518 弄'
      }, {
        registe_time: '2016-05-04',
        username: '王小虎',
        city: '上海市普陀区金沙江路 1517 弄'
      }, {
        registe_time: '2016-05-01',
        username: '王小虎',
        city: '上海市普陀区金沙江路 1519 弄'
      }, {
        registe_time: '2016-05-03',
        username: '王小虎',
        city: '上海市普陀区金沙江路 1516 弄'
      }],
      currentRow: null, // 当前选中的行
      offset: 0,  // 偏移量
      limit: 20,  // 限制多少条
      count: 0, // 数据总条数
      currentPage: 1, // 当前选中的页
    }
  },
  components: {
    headTop,
  },
  created() {
    this.initData();
  },
  methods: {
    // 初始化数据
    async initData() {
      try {
        const countData = await getUserCount();
        if (countData.status == 1) {
          this.count = countData.count; // 获取总页数
        } else {
          throw new Error('获取数据失败');
        }
        this.getUsers(); // 前端分页
      } catch (err) {
        console.log('获取数据失败', err);
      }
    },
    // 每页多少条
    handleSizeChange(val) {
      console.log(`每页 ${val} 条`);
    },
    // 当前是第几页
    handleCurrentChange(val) {
      this.currentPage = val;
      this.offset = (val - 1) * this.limit;
      this.getUsers()
    },
    // 获取用户列表
    async getUsers() {
      const Users = await getUserList({ offset: this.offset, limit: this.limit });
      this.tableData = [];
      Users.forEach(item => {
        const tableData = {};
        tableData.username = item.username;
        tableData.registe_time = item.registe_time;
        tableData.city = item.city;
        this.tableData.push(tableData);
      })
    }
  },
}
</script>

<style lang="less">
@import '../style/mixin';
.table_container {
  padding: 20px;
}
</style>
