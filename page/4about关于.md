---
layout: about
title: 关于
permalink: /about/
icon: heart
type: page
---






<h1>日益变肥~~~</h1>
        
<hr>
		
<!-- Language Selector -->
<select  onchange= "onLanChange(this.options[this.options.selectedIndex].value)">
    <option value="0" selected> 中文 Chinese </option>
    <option value="1"> 英文 English </option>
</select>

<!-- Chinese Version -->
<div class="zh post-container">

  <p>在挂科的边缘挣扎，努力攻读凝聚态博士学位中。。。。</p>

  <p>一直很幸运，一直在做自己喜欢的事，每天都有做不完的作业<br>
  什么都很好奇，什么也没做成<br>
  已经是一个废宅了</p>
  
  <p>学习经历</p>
  <ul>
    <li> 2014 山东大学</li>
    <li> 2018 中国科学院大学</li>
  </ul>

</div>

<!-- English Version -->
<div class="en post-container">
  <p>Hi, here is cndaqiang. I'm studing in University of Chinese Academy of Sciences. I am working hard to get my Ph.D. in condensed matter physics.</p>
  <p>I am sorry for my poor English. But if you have anything to share with me, just go ahead. I'm willing to talk and share.<br>
  And I think Email is the best way: chendq@aliyun.com </p>

  <p>If you want to know more about me, here is what I can do:</p>

  <ul>
    <li>2014 Shandong University </li>
    <li>2018 University of Chinese Academy of Sciences</li>
  </ul>
</div>

<!-- Handle Language Change -->
<script type="text/javascript">
    // get nodes
    var $zh = document.querySelector(".zh");
    var $en = document.querySelector(".en");
    var $select = document.querySelector("select");
    // bind hashchange event
    window.addEventListener('hashchange', _render);
    // handle render
    function _render(){
        var _hash = window.location.hash;
        // en
        if(_hash == "#en"){
            $select.selectedIndex = 1;
            $en.style.display = "block";
            $zh.style.display = "none";
        // zh by default
        }else{
            // not trigger onChange, otherwise cause a loop call.
            $select.selectedIndex = 0;
            $zh.style.display = "block";
            $en.style.display = "none";
        }
    }
    // handle select change
    function onLanChange(index){
        if(index == 0){
            window.location.hash = "#zh"
        }else{
            window.location.hash = "#en"
        }
    }
    // init
    _render();
</script>

<hr>

