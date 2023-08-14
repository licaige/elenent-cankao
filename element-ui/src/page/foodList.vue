<template>
  <div class="fillcontain">
    <head-top></head-top>
    <div class="table_container">
      <!-- 表格 -->
      <el-table :data="tableData" @expand='expand' :expand-row-keys='expendRow' :row-key="row => row.index" style="width: 100%">
        <el-table-column type="expand">
          <template scope="props">
            <el-form label-position="left" inline class="demo-table-expand">
              <el-form-item label="食品名称">
                <span>{{ props.row.name }}</span>
              </el-form-item>
              <el-form-item label="餐馆名称">
                <span>{{ props.row.restaurant_name }}</span>
              </el-form-item>
              <el-form-item label="食品 ID">
                <span>{{ props.row.item_id }}</span>
              </el-form-item>
              <el-form-item label="餐馆 ID">
                <span>{{ props.row.restaurant_id }}</span>
              </el-form-item>
              <el-form-item label="食品介绍">
                <span>{{ props.row.description }}</span>
              </el-form-item>
              <el-form-item label="餐馆地址">
                <span>{{ props.row.restaurant_address }}</span>
              </el-form-item>
              <el-form-item label="食品评分">
                <span>{{ props.row.rating }}</span>
              </el-form-item>
              <el-form-item label="食品分类">
                <span>{{ props.row.category_name }}</span>
              </el-form-item>
              <el-form-item label="月销量">
                <span>{{ props.row.month_sales }}</span>
              </el-form-item>
            </el-form>
          </template>
        </el-table-column>
        <el-table-column label="食品名称" prop="name">
        </el-table-column>
        <el-table-column label="食品介绍" prop="description">
        </el-table-column>
        <el-table-column label="评分" prop="rating">
        </el-table-column>
        <el-table-column label="操作" width="160">
          <template scope="scope">
            <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.$index, scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页 -->
      <div class="Pagination">
        <el-pagination @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page="currentPage" :page-size="20" layout="total, prev, pager, next" :total="count">
        </el-pagination>
      </div>
      <!-- 修改弹窗 -->
      <el-dialog title="修改食品信息" v-model="dialogFormVisible">
        <el-form :model="selectTable">
          <el-form-item label="食品名称" label-width="100px">
            <el-input v-model="selectTable.name" auto-complete="off"></el-input>
          </el-form-item>
          <el-form-item label="食品介绍" label-width="100px">
            <el-input v-model="selectTable.description"></el-input>
          </el-form-item>
          <el-form-item label="食品分类" label-width="100px">
            <el-select v-model="selectIndex" :placeholder="selectMenu.label" @change="handleSelect">
              <el-option v-for="item in menuOptions" :key="item.value" :label="item.label" :value="item.index">
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="食品图片" label-width="100px">
            <el-upload class="avatar-uploader" :action="baseUrl + '/v1/addimg/food'" :show-file-list="false" :on-success="handleServiceAvatarScucess" :before-upload="beforeAvatarUpload">
              <img v-if="selectTable.image_path" :src="baseImgPath + selectTable.image_path" class="avatar">
              <i v-else class="el-icon-plus avatar-uploader-icon"></i>
            </el-upload>
          </el-form-item>
        </el-form>
        <!-- 添加规格列表展示 -->
        <el-row style="overflow: auto; text-align: center;">
          <el-table :data="specs" style="margin-bottom: 20px;" :row-class-name="tableRowClassName">
            <el-table-column prop="specs" label="规格">
            </el-table-column>
            <el-table-column prop="packing_fee" label="包装费">
            </el-table-column>
            <el-table-column prop="price" label="价格">
            </el-table-column>
            <el-table-column label="操作">
              <template scope="scope">
                <el-button size="small" type="danger" @click="deleteSpecs(scope.$index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-button type="primary" @click="specsFormVisible = true" style="margin-bottom: 10px;">添加规格</el-button>
        </el-row>
        <div slot="footer" class="dialog-footer">
          <el-button @click="dialogFormVisible = false">取 消</el-button>
          <el-button type="primary" @click="updateFood">确 定</el-button>
        </div>
      </el-dialog>
      <!-- 添加规格弹窗 -->
      <el-dialog title="添加规格" v-model="specsFormVisible">
        <el-form :rules="specsFormrules" :model="specsForm">
          <el-form-item label="规格" label-width="100px" prop="specs">
            <el-input v-model="specsForm.specs" auto-complete="off"></el-input>
          </el-form-item>
          <el-form-item label="包装费" label-width="100px">
            <el-input-number v-model="specsForm.packing_fee" :min="0" :max="100"></el-input-number>
          </el-form-item>
          <el-form-item label="价格" label-width="100px">
            <el-input-number v-model="specsForm.price" :min="0" :max="10000"></el-input-number>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button @click="specsFormVisible = false">取 消</el-button>
          <el-button type="primary" @click="addspecs">确 定</el-button>
        </div>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import headTop from '../components/headTop'
import { baseUrl, baseImgPath } from '@/config/env'
import { getFoods, getFoodsCount, getMenu, updateFood, deleteFood, getResturantDetail, getMenuById } from '@/api/getData'
export default {
  data() {
    return {
      baseUrl,
      baseImgPath,
      restaurant_id: null, // 商家id
      city: {}, // 所在城市
      offset: 0, // 开始位置
      limit: 20, // 每页条数
      count: 0, // 总条数
      tableData: [], // 表格数据
      currentPage: 1, // 当前页
      selectTable: {}, // 选中的表格当前行的数据
      dialogFormVisible: false, // 修改弹窗
      menuOptions: [], // 食品分类下拉菜单
      selectMenu: {}, // 下拉菜单默认选中
      selectIndex: null, // 下拉菜单绑定的索引值
      specsForm: { // 规格的表单数据
        specs: '',
        packing_fee: 0,
        price: 20,
      },
      specsFormrules: { // 规格表单的规则
        specs: [
          { required: true, message: '请输入规格', trigger: 'blur' },
        ],
      },
      specsFormVisible: false, // 增加规格弹窗
      expendRow: [], // 展开行的 keys 数组
    }
  },
  created() {
    this.restaurant_id = this.$route.query.restaurant_id;
    this.initData();
  },
  computed: {
    // 规格绑定的表格数据
    specs: function () {
      let specs = [];
      if (this.selectTable.specfoods) {
        this.selectTable.specfoods.forEach(item => {
          specs.push({
            specs: item.specs_name,
            packing_fee: item.packing_fee,
            price: item.price,
          })
        })
      }
      return specs
    }
  },
  components: {
    headTop,
  },
  methods: {
    // 初始化数据
    async initData() {
      try {
        const countData = await getFoodsCount({ restaurant_id: this.restaurant_id });
        if (countData.status == 1) {
          this.count = countData.count;
        } else {
          throw new Error('获取数据失败');
        }
        this.getFoods();
      } catch (err) {
        console.log('获取数据失败', err);
      }
    },
    // 获取商品分类
    async getMenu() {
      this.menuOptions = [];
      try {
        const menu = await getMenu({ restaurant_id: this.selectTable.restaurant_id, allMenu: true });
        // 获得下拉列表数据
        menu.forEach((item, index) => {
          this.menuOptions.push({
            label: item.name,
            value: item.id,
            index,
          })
        })
      } catch (err) {
        console.log('获取食品种类失败', err);
      }
    },
    // 获取商品列表
    async getFoods() {
      const Foods = await getFoods({ offset: this.offset, limit: this.limit, restaurant_id: this.restaurant_id });
      this.tableData = [];
      // 渲染数据到表格
      Foods.forEach((item, index) => {
        const tableData = {};
        tableData.name = item.name;
        tableData.item_id = item.item_id;
        tableData.description = item.description;
        tableData.rating = item.rating;
        tableData.month_sales = item.month_sales;
        tableData.restaurant_id = item.restaurant_id;
        tableData.category_id = item.category_id;
        tableData.image_path = item.image_path;
        tableData.specfoods = item.specfoods;
        tableData.index = index;
        this.tableData.push(tableData);
      })
    },
    // 动态绑定类名(没发现啥用)
    tableRowClassName(row, index) {
      console.log('tableRowClassName: ', row, index);
      if (index === 1) {
        return 'info-row';
      } else if (index === 3) {
        return 'positive-row';
      }
      return '';
    },
    // 新增规格
    addspecs() {
      this.specs.push({ ...this.specsForm });
      // 清空数据关闭弹窗
      this.specsForm.specs = '';
      this.specsForm.packing_fee = 0;
      this.specsForm.price = 20;
      this.specsFormVisible = false;
    },
    // 添加规格列表行的删除
    deleteSpecs(index) {
      this.specs.splice(index, 1);
    },
    // 每页显示多少条
    handleSizeChange(val) {
      console.log(`每页 ${val} 条`);
    },
    // 页码发生变化
    handleCurrentChange(val) {
      this.currentPage = val;
      this.offset = (val - 1) * this.limit;
      this.getFoods()
    },
    // 当用户对某一行展开或者关闭的上会触发该事件
    expand(row, status) {
      console.log('展开行：', row, status);
      if (status) {
        // 展开获取数据
        this.getSelectItemData(row)
      } else {
        // 合并清空数据
        const index = this.expendRow.indexOf(row.index);
        this.expendRow.splice(index, 1)
      }
    },
    // 点击编辑按钮
    handleEdit(row) {
      // 请求要展示的信息
      this.getSelectItemData(row, 'edit')
      // 编辑表单弹窗
      this.dialogFormVisible = true;
    },
    // 编辑表单事件
    async getSelectItemData(row, type) {
      // 获取餐馆详细信息
      const restaurant = await getResturantDetail(row.restaurant_id);
      // 获取menu详情
      const category = await getMenuById(row.category_id)
      // 对象的解构赋值, 把对应的值合并并赋值给selectTable
      this.selectTable = { ...row, ...{ restaurant_name: restaurant.name, restaurant_address: restaurant.address, category_name: category.name } };
      // 下拉菜单中默认选中的值
      this.selectMenu = { label: category.name, value: row.category_id }
      // 像当前列表中添加下拉列表数据
      this.tableData.splice(row.index, 1, { ...this.selectTable });
      this.$nextTick(() => {
        this.expendRow.push(row.index);
      })
      // 判断如果是编辑状态并且餐馆的id和要编辑的餐馆id不一致时从新请求商家食品下拉列表
      if (type == 'edit' && this.restaurant_id != row.restaurant_id) {
        this.getMenu();
      }
    },
    // 下拉菜单
    handleSelect(index) {
      this.selectIndex = index;
      this.selectMenu = this.menuOptions[index];
    },
    // 删除所在行的食品
    async handleDelete(index, row) {
      try {
        const res = await deleteFood(row.item_id);
        if (res.status == 1) {
          this.$message({
            type: 'success',
            message: '删除食品成功'
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
        console.log('删除食品失败')
      }
    },
    // 上传文件成功时的回调函数
    handleServiceAvatarScucess(res, file) {
      if (res.status == 1) {
        this.selectTable.image_path = res.image_path;
      } else {
        this.$message.error('上传图片失败！');
      }
    },
    // 上传图片之前触发的函数
    beforeAvatarUpload(file) {
      // 文件类型
      const isRightType = (file.type === 'image/jpeg') || (file.type === 'image/png');
      // 文件大小
      const isLt2M = file.size / 1024 / 1024 < 2;

      if (!isRightType) {
        this.$message.error('上传头像图片只能是 JPG 格式!');
      }
      if (!isLt2M) {
        this.$message.error('上传头像图片大小不能超过 2MB!');
      }
      return isRightType && isLt2M;
    },
    // 更新商品信息
    async updateFood() {
      // 关闭弹窗
      this.dialogFormVisible = false;
      try {
        const subData = { new_category_id: this.selectMenu.value, specs: this.specs };
        const postData = { ...this.selectTable, ...subData };
        // 发送要保存的数据信息
        const res = await updateFood(postData)
        if (res.status == 1) {
          this.$message({
            type: 'success',
            message: '更新食品信息成功'
          });
          this.getFoods();
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
