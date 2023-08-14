<template>
  <div class="fillcontain">
    <!-- 头部 -->
    <head-top></head-top>
    <div class="table_container">
      <!-- 表格数据展示 -->
      <el-table :data="tableData" style="width: 100%">
        <!-- 可展开 -->
        <el-table-column type="expand">
          <!-- 展开模版 -->
          <template scope="props">
            <el-form label-position="left" inline class="demo-table-expand">
              <el-form-item label="店铺名称">
                <span>{{ props.row.name }}</span>
              </el-form-item>
              <el-form-item label="店铺地址">
                <span>{{ props.row.address }}</span>
              </el-form-item>
              <el-form-item label="店铺介绍">
                <span>{{ props.row.description }}</span>
              </el-form-item>
              <el-form-item label="店铺 ID">
                <span>{{ props.row.id }}</span>
              </el-form-item>
              <el-form-item label="联系电话">
                <span>{{ props.row.phone }}</span>
              </el-form-item>
              <el-form-item label="评分">
                <span>{{ props.row.rating }}</span>
              </el-form-item>
              <el-form-item label="销售量">
                <span>{{ props.row.recent_order_num }}</span>
              </el-form-item>
              <el-form-item label="分类">
                <span>{{ props.row.category }}</span>
              </el-form-item>
            </el-form>
          </template>
        </el-table-column>
        <el-table-column label="店铺名称" prop="name">
        </el-table-column>
        <el-table-column label="店铺地址" prop="address">
        </el-table-column>
        <el-table-column label="店铺介绍" prop="description">
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template scope="scope">
            <!-- 这一行的数据进行操作 -->
            <el-button size="mini" @click="handleEdit(scope.$index, scope.row)">编辑</el-button>
            <el-button size="mini" type="Success" @click="addFood(scope.$index, scope.row)">添加食品</el-button>
            <el-button size="mini" type="danger" @click="handleDelete(scope.$index, scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页块 -->
      <div class="Pagination">
        <el-pagination @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page="currentPage" :page-size="20" layout="total, prev, pager, next" :total="count">
        </el-pagination>
      </div>

      <!-- dialog：弹出框(编辑时触发) -->
      <el-dialog title="修改店铺信息" v-model="dialogFormVisible">
        <!-- 表单 -->
        <el-form :model="selectTable">
          <el-form-item label="店铺名称" label-width="100px">
            <el-input v-model="selectTable.name" auto-complete="off"></el-input>
          </el-form-item>
          <el-form-item label="详细地址" label-width="100px">
            <!-- 获取当前城市附近的位置 -->
            <el-autocomplete v-model="address.address" :fetch-suggestions="querySearchAsync" placeholder="请输入地址" style="width: 100%;" @select="addressSelect"></el-autocomplete>
            <span>当前城市：{{city.name}}</span>
          </el-form-item>
          <el-form-item label="店铺介绍" label-width="100px">
            <el-input v-model="selectTable.description"></el-input>
          </el-form-item>
          <el-form-item label="联系电话" label-width="100px">
            <el-input v-model="selectTable.phone"></el-input>
          </el-form-item>
          <el-form-item label="店铺分类" label-width="100px">
            <el-cascader :options="categoryOptions" v-model="selectedCategory" change-on-select></el-cascader>
          </el-form-item>
          <el-form-item label="商铺图片" label-width="100px">
            <!-- 上传图片 -->
            <el-upload class="avatar-uploader" :action="baseUrl + '/v1/addimg/shop'" :show-file-list="false" :on-success="handleServiceAvatarScucess" :before-upload="beforeAvatarUpload">
              <!-- 文件上传成功显示 -->
              <img v-if="selectTable.image_path" :src="baseImgPath + selectTable.image_path" class="avatar">
              <!-- 否则显示添加文件 -->
              <i v-else class="el-icon-plus avatar-uploader-icon"></i>
            </el-upload>
          </el-form-item>
        </el-form>
        <!-- dialog: 底部插槽，添加按钮操作 -->
        <div slot="footer" class="dialog-footer">
          <el-button @click="dialogFormVisible = false">取 消</el-button>
          <el-button type="primary" @click="updateShop">确 定</el-button>
        </div>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import headTop from '../components/headTop'
// 导入存储的路径
import { baseUrl, baseImgPath } from '@/config/env'
// 导入api
import { cityGuess, getResturants, getResturantsCount, foodCategory, updateResturant, searchplace, deleteResturant } from '@/api/getData'
export default {
  data() {
    return {
      baseUrl,
      baseImgPath,
      city: {}, // 当前城市信息
      offset: 0, // 第几页开始
      limit: 20, // 每页条数
      count: 0, // 总条数
      tableData: [], // 列表数据
      currentPage: 1, // 当前页
      selectTable: {}, // 要编辑的当前行的数据
      dialogFormVisible: false, // 编辑时显示的弹窗
      categoryOptions: [], // 店铺的种类全部数据
      selectedCategory: [], // 选中的店铺
      address: {}, // 地址
    }
  },
  created() {
    this.initData(); // 初始化数据
  },
  components: {
    headTop,
  },
  methods: {
    async initData() {
      try {
        // 获取所在城市的定位信息
        this.city = await cityGuess();
        // 获取餐馆数量
        const countData = await getResturantsCount();
        if (countData.status == 1) {
          this.count = countData.count;
        } else {
          throw new Error('获取数据失败');
        }
        this.getResturants();
      } catch (err) {
        console.log('获取数据失败', err);
      }
    },
    // 请求商品种类列表
    async getCategory() {
      try {
        const categories = await foodCategory();
        console.log('商品种类: ', categories);
        // 商品种类列表
        categories.forEach(item => {
          if (item.sub_categories.length) {
            // 添加到对象中
            const addnew = {
              value: item.name,
              label: item.name,
              children: []
            }
            item.sub_categories.forEach((subitem, index) => {
              if (index == 0) {
                return
              }
              // 添加子数据
              addnew.children.push({
                value: subitem.name,
                label: subitem.name,
              })
            })
            // 把数据放到指定的下拉菜单中
            this.categoryOptions.push(addnew)
          }
        })
      } catch (err) {
        console.log('获取商铺种类失败', err);
      }
    },
    // 获取餐馆列表
    async getResturants() {
      // 对象的解构赋值, 获得城市的经纬度
      const { latitude, longitude } = this.city;
      console.debug('this.city: ', this.city);
      // 传入请求参数
      const restaurants = await getResturants({ latitude, longitude, offset: this.offset, limit: this.limit });
      // 清空数据
      this.tableData = [];
      restaurants.forEach(item => {
        const tableData = {};
        tableData.name = item.name;
        tableData.address = item.address;
        tableData.description = item.description;
        tableData.id = item.id;
        tableData.phone = item.phone;
        tableData.rating = item.rating;
        tableData.recent_order_num = item.recent_order_num;
        tableData.category = item.category;
        tableData.image_path = item.image_path;
        // 拿到获取的每个对象的值
        this.tableData.push(tableData);
      })
    },
    // 每页显示多少条
    handleSizeChange(val) {
      console.log(`每页 ${val} 条`);
    },
    // 当前页数
    handleCurrentChange(val) {
      this.currentPage = val;
      this.offset = (val - 1) * this.limit;
      // 请求参数发生变化，重新请求数据
      this.getResturants()
    },
    // 对列表中的单行数据进行编辑
    handleEdit(index, row) {
      // 获取每一行的数据
      this.selectTable = row;
      console.log('row', row);
      // 获取地址信息
      this.address.address = row.address;
      // 显示弹窗
      this.dialogFormVisible = true;
      // 把获取的字符串分割为数组(默认地址)
      this.selectedCategory = row.category.split('/');
      // 判断店铺列表是否存在
      if (!this.categoryOptions.length) {
        this.getCategory();
      }
    },
    // 添加食品
    addFood(index, row) {
      // 传入商家的id, 跳转页面
      this.$router.push({ path: 'addGoods', query: { restaurant_id: row.id } })
    },
    // 删除餐馆
    async handleDelete(index, row) {
      try {
        // 传入要删除的餐馆id
        const res = await deleteResturant(row.id);
        if (res.status == 1) {
          this.$message({
            type: 'success',
            message: '删除店铺成功'
          });
          this.tableData.splice(index, 1);
        } else {
          throw new Error(res.message)
        }
      } catch (err) {
        this.$message({
          type: 'error',
          message: err.message
        });
        console.log('删除店铺失败')
      }
    },
    // 自动填充搜索内容
    async querySearchAsync(queryString, cb) {
      // 输入的字符串
      if (queryString) {
        try {
          // 获取搜索地址
          const cityList = await searchplace(this.city.id, queryString);
          console.log('cityList: ', cityList);
          // 判断列表是否是一个数组
          if (cityList instanceof Array) {
            cityList.map(item => {
              item.value = item.address;
              return item;
            })
            cb(cityList)
          }
        } catch (err) {
          console.log(err)
        }
      }
    },
    // 选中address
    addressSelect(vale) {
      // 把传入的参数解构赋值
      const { address, latitude, longitude } = vale;
      // 存入到address中, 重新刷新数据
      this.address = { address, latitude, longitude };
    },
    // 文件上传成功时的回调函数
    handleServiceAvatarScucess(res, file) {
      if (res.status == 1) {
        // 成功显示图片
        this.selectTable.image_path = res.image_path;
      } else {
        this.$message.error('上传图片失败！');
      }
    },
    // 图片上传之前监听事件
    beforeAvatarUpload(file) {
      // 判断上传文件的类型为jepg/png
      const isRightType = (file.type === 'image/jpeg') || (file.type === 'image/png');
      // 文件大小不的大于2M
      const isLt2M = file.size / 1024 / 1024 < 2;

      // 判断
      if (!isRightType) {
        this.$message.error('上传头像图片只能是 JPG 格式!');
      }
      if (!isLt2M) {
        this.$message.error('上传头像图片大小不能超过 2MB!');
      }
      return isRightType && isLt2M;
    },
    // 保存商品信息
    async updateShop() {
      this.dialogFormVisible = false;
      try {
        // 合并请求参数
        Object.assign(this.selectTable, this.address);
        // 把选择的商品分类改为字符串存储
        this.selectTable.category = this.selectedCategory.join('/');
        // 发送请求 更新餐馆信息
        const res = await updateResturant(this.selectTable)
        if (res.status == 1) {
          this.$message({
            type: 'success',
            message: '更新店铺信息成功'
          });
          // 刷新页面
          this.getResturants();
        } else {
          this.$message({
            type: 'error',
            message: res.message
          });
        }
      } catch (err) {
        console.log('更新餐馆信息失败', err);
      }
    },
  },
}
</script>

<style lang="less">
@import '../style/mixin';
.demo-table-expand {
  font-size: 0;
}

.demo-table-expand label {
  width: 90px;
  color: #99a9bf;
}

.demo-table-expand .el-form-item {
  margin-right: 0;
  margin-bottom: 0;
  width: 50%;
}

.table_container {
  padding: 20px;
}

.Pagination {
  display: flex;
  justify-content: flex-start;
  margin-top: 8px;
}

.avatar-uploader .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.avatar-uploader .el-upload:hover {
  border-color: #20a0ff;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 120px;
  height: 120px;
  line-height: 120px;
  text-align: center;
}

.avatar {
  width: 120px;
  height: 120px;
  display: block;
}
</style>
