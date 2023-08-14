﻿# sg-utils

> JavaScript通用工具类

#### 1、使用实例

> [JavaScript工具类：util.js用法实例](https://blog.csdn.net/guang_s/article/details/88119343)

#### 2、API说明

> util.js 文件里面对每个方法的参数做了说明，参照具体方法说明即可。如下：

```javascript
(function (window) {
    var u = {};

    u.date = {};

    /**
     * @description 获取需要的时间格式
     * @param {Date} time 时间、时间字符串、时间戳
     * @param {String} format 时间格式，默认'YYYY-MM-DD'。如果是'星期WW'，则返回（如：'星期日'）
     * @return {String} 格式化后的时间
     */
    u.date.format = function (time, format){
        time = time ? new Date(time) : new Date();
        format = format || 'YYYY-MM-DD';
        function tf(i){ return (i < 10 ? '0' : '') + i; }
        return format.replace(/YYYY|MM|DD|hh|mm|ss|WW/g, function(a){
            switch(a){
                case 'YYYY':
                    return tf(time.getFullYear());
                case 'MM':
                    return tf(time.getMonth() + 1);
                case 'DD':
                    return tf(time.getDate());
                case 'mm':
                    return tf(time.getMinutes());
                case 'hh':
                    return tf(time.getHours());
                case 'ss':
                    return tf(time.getSeconds());
                case 'WW':
                    return ['日', '一', '二', '三', '四', '五', '六'][time.getDay()];
            }
        });
    };

    window._util = u;
})(window);
```

#### 3、npm下载

```
npm i sg-utils -S
```

#### 4、github地址

> [https://github.com/shiguang0116/sg-utils](https://github.com/shiguang0116/sg-utils)

#### 5、文件说明

```
sg-utils/
├── example/
│   ├── index.html       util.js用法实例文档
│   └── index.js         util.js的方法调用，可编辑代码，然后在index.html控制台查看输出结果
├── src/
│   ├── util.js         通用工具类，引入该文件即可使用变量_util，及所有方法。建议复制到项目中以便扩展；
│   ├── service.js      服务工具类的基本架构。可复制到项目中以便参考扩展；
│   └── filter.js       过滤器（基于art-template模板）。可复制到项目中以便参考扩展；
└── index.js            项目引用文件
```
