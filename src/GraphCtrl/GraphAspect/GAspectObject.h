/***************************
@Author: Chunel
@Contact: chunel@foxmail.com
@File: GAspectObject.h
@Time: 2021/10/2 9:46 下午
@Desc: 
***************************/

#ifndef CGRAPH_GASPECTOBJECT_H
#define CGRAPH_GASPECTOBJECT_H

#include <string>

#include "GAspectDefine.h"
#include "../GraphObject.h"
#include "../GraphParam/GParamInclude.h"

class GAspectObject : public GraphObject {
public:
    ~GAspectObject() override {
        CGRAPH_DELETE_PTR(param_)
    }

    /**
     * 获取name信息
     * @return
     */
    virtual const std::string& getName() final {
        return name_;
    }

    /**
     * 获取切面参数内容
     * @return
     */
    template <typename T = GAspectParam,
              std::enable_if_t<std::is_base_of_v<GAspectParam, T>, int> = 0>
    T* getParam();

    /**
     * 设置切面参数内容
     * @param param
     */
    template <typename T,
              std::enable_if_t<std::is_base_of_v<GAspectParam, T>, int> = 0>
    GAspectObject* setParam(T* param);

protected:
    /**
     * 设置名称
     * @param name
     */
    virtual void setName(const std::string& name) {
        this->name_ = name;
    }

    /**
     * GAspect 相关内容，不需要执行run方法
     * @return
     */
    CSTATUS run() final {
        CGRAPH_NO_SUPPORT;
    }

private:
    std::string name_;                       // 切面类名称，跟element名称保持相同
    GAspectParamPtr param_ { nullptr };            // 参数信息

    friend class GAspectManager;
    friend class GElement;
};

using GAspectObjectPtr = GAspectObject *;

#include "GAspectObject.inl"

#endif //CGRAPH_GASPECTOBJECT_H