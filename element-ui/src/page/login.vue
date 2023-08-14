<template>
	<div class="login_page fillcontain">
		<transition name="form-fade" mode="in-out">
			<section class="form_contianer" v-show="showLogin">
				<!--登录页面的提示信息 -->
				<div class="manage_tip">
					<p>elm后台管理系统</p>
				</div>
				<!--登录的表单 -->
				<el-form :model="loginForm" :rules="rules" ref="loginForm">
					<el-form-item prop="username">
						<el-input v-model="loginForm.username" placeholder="用户名">
							<span>dsfsf</span>
						</el-input>
					</el-form-item>
					<el-form-item prop="password">
						<el-input type="password" placeholder="密码" v-model="loginForm.password"></el-input>
					</el-form-item>
					<el-form-item>
						<el-button type="primary" @click="submitForm('loginForm')" class="submit_btn">登陆</el-button>
					</el-form-item>
				</el-form>
				<!--表单的提示信息 -->
				<p class="tip">温馨提示：</p>
				<p class="tip">未登录过的新用户，自动注册</p>
				<p class="tip">注册过的用户可凭账号密码登录</p>
			</section>
		</transition>
	</div>
</template>

<script>
// 导入两个方法
import { login, getAdminInfo } from '@/api/getData'
import { mapActions, mapState } from 'vuex'

export default {
	data() {
		return {
			loginForm: {
				username: '', // 用户
				password: '', // 密码
			},
			rules: {
				username: [
					{ required: true, message: '请输入用户名', trigger: 'blur' }, // 用户名验证规则
				],
				password: [
					{ required: true, message: '请输入密码', trigger: 'blur' }, // 密码验证规则
				],
			},
			showLogin: false, // 显示/隐藏表单
		}
	},
	mounted() {
		// 页面渲染时触发的事件
		this.showLogin = true; // 显示login
		if (!this.adminInfo.id) {
			this.getAdminData() // 如果用户存在，则调用用户的数据信息
		}
	},
	computed: {
		...mapState(['adminInfo']),
	},
	methods: {
		// 调用vuex中的action
		...mapActions(['getAdminData']),
		// 提交表单事件
		async submitForm(formName) {
			// 传入参数字符串, 进行表单验证
			this.$refs[formName].validate(async (valid) => {
				if (valid) {
					// 验证成功, 传入参数
					const res = await login({ user_name: this.loginForm.username, password: this.loginForm.password })
					if (res.status == 1) {
						// 弹出提示信息
						this.$message({
							type: 'success',
							message: '登录成功'
						});
						// 跳转页面
						this.$router.push('manage')
					} else {
						this.$message({
							type: 'error',
							message: res.message
						});
					}
				} else {
					// 侧边提示信息
					this.$notify.error({
						title: '错误',
						message: '请输入正确的用户名密码',
						offset: 100
					});
					return false;
				}
			});
		},
	},
	watch: {
		adminInfo: function (old, newValue) {
			console.log(old, newValue);
			if (newValue.id) {
				this.$message({
					type: 'success',
					message: '检测到您之前登录过，将自动登录'
				});
				this.$router.push('manage')
			}
		}
	}
}
</script>

<style lang="less" scoped>
@import '../style/mixin';
.login_page {
	background-color: #324057;
}

.manage_tip {
	position: absolute;
	width: 100%;
	top: -100px;
	left: 0;
	p {
		font-size: 34px;
		color: #fff;
	}
}

.form_contianer {
	.wh(320px, 210px);
	.ctp(320px, 210px);
	padding: 25px;
	border-radius: 5px;
	text-align: center;
	background-color: #fff;
	.submit_btn {
		width: 100%;
		font-size: 16px;
	}
}

.tip {
	font-size: 12px;
	color: red;
}

.form-fade-enter-active,
.form-fade-leave-active {
	transition: all 1s;
}

.form-fade-enter,
.form-fade-leave-active {
	transform: translate3d(0, -50px, 0);
	opacity: 0;
}
</style>
