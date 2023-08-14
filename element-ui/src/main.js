import Vue from 'vue'
import App from './App'
import router from './router' // 路由
import store from './store/' // vuex
import ElementUI from 'element-ui' // xuex
import 'element-ui/lib/theme-default/index.css' // 默认主题

Vue.config.productionTip = false;

Vue.use(ElementUI);

new Vue({
	el: '#app',
	router,
	store,
	template: '<App/>',
	components: { App }
})
