<template>
<!-- 主题配置右侧编辑器顶部部分 -->
  <div class="configurator-action">
      <div class="action-group">
        <!-- 撤销 -->
        <el-tooltip :content="getActionDisplayName('undo')">
          <img
            src="../../assets/images/icon-undo.svg"
            @click="onUndo"
            :class="{ 'active': userConfigHistory.length > 0 }"
          />
        </el-tooltip>
        <!-- 重做 -->
        <el-tooltip :content="getActionDisplayName('redo')">
          <img
            src="../../assets/images/icon-redo.svg"
            @click="onRedo"
            :class="{ 'active': userConfigRedoHistory.length > 0 }"
          />
        </el-tooltip>
        <div class="button-group">
          <!-- 重置 -->
          <el-button
            class="reset"
            type="primary"
            round
            size="mini"
            :disabled="isOfficial"
            @click="onReset"
          >
            {{getActionDisplayName('reset-theme')}}
          </el-button>
          <!-- 下载 -->
          <el-button
            class="download"
            type="primary"
            round
            size="mini"
            :disabled="downloadDisabled"
            @click="onDownload"
          >
            {{getActionDisplayName('download-theme')}}
          </el-button>
        </div>
      </div>
      <!-- 右侧组件主题配置下拉菜单 -->
      <el-select v-model="selectedComponent" class="selector">
        <el-option
          v-for="item in selectOptions"
          :key="item.value"
          :label="item.label"
          :value="item.value">
        </el-option>
      </el-select>
      <div class="line"></div>
    </div>
</template>

<style lang="scss">
.configurator-action {
  padding: 15px 18px 0;
  .action-group {
    padding: 5px 0;
    img {
      cursor: not-allowed;
      width: 16px;
      height: 16px;
      padding: 7px 0;
      margin-left: 5px;
      opacity: .5;
      &.active {
        opacity: 1;
        cursor: pointer;
      }
      &:last-of-type {
        margin-left: 10px;
      }
    }
    .button-group {
      float: right;
      .el-button {
        padding: 6px 15px;
        &.is-disabled {
          color: #C0C4CC;
          background-color: #fff;
          border-color: #EBEEF5;
        }
      }
      .reset {
        background: #E6F1FC;
        color: #1989FA;
        border-color: #A2CFFC;
      }
      .download {
        background: #1989FA;
        color: #FFF;
        border-color: #1989FA
      }
    }
  }
  .selector {
    width: 100%;
    input {
      background: #f5f7fa;
      border: none;
      font-size: 18px;
      padding-left: 0;
      color: #606266;
    }
  }
  .line {
    width: 100%;
    height: 0;
    border-bottom: 1px solid #DCDFE6;
  }
}
</style>

<script>
import { getActionDisplayName } from './utils/utils';
export default {
  props: {
    selectOptions: Array,
    userConfigHistory: Array,
    userConfigRedoHistory: Array,
    isOfficial: Boolean,
    onUndo: Function,
    onRedo: Function
  },
  data() {
    return {
      selectedComponent: 'color',
      downloadDisabled: false
    };
  },
  watch: {
    selectedComponent: {
      handler(val) {
        this.$emit('select', val);
      }
    }
  },
  methods: {
    getActionDisplayName(key) {
      return getActionDisplayName(key);
    },
    onReset() {
      // 指向 examples/components/theme-configurator/index.vue 的 onReset 方法
      this.$parent.onReset();
    },
    // 指向 examples/components/theme-configurator/index.vue 的 onDownload 方法
    onDownload() {
      this.downloadDisabled = true;
      this.$parent.onDownload();
      setTimeout(() => {
        this.downloadDisabled = false;
      }, 2500);
    }
  }
};
</script>
