#include <scenenode.h>
#include <glinc.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
//#include <glm/gtc/matrix_transform.hpp>
using namespace sc;
using namespace std;

ComponentType SceneNode::type = {
    "SceneNode",
    "Keeps track of relative transformations and methods for drawing objects",
    NULL
};

const ComponentType* const SceneNode::getComponentType()
    {return &type;}

SceneNode::SceneNode()
{
    t = mat4(1.f);
    f = nulldrawfunc;
    parent = NULL;
    children = vector<SceneNode*>();
    owner = NULL;
}

SceneNode::SceneNode(SceneNode* parent, Entity* owner)
{
    t = mat4(1.f);
    f = nulldrawfunc;
    this->parent = parent;
    parent->children.push_back(this);
    children = vector<SceneNode*>();
    if(owner)
    {
        this->owner = owner;
        owner->addComponent(this);
    }
    else
        this->owner = NULL;
}

SceneNode::~SceneNode()
{
    u32 size = (u32)children.size();
    for(u32 i = 0; i < size; i++)
        delete children[i];
    if(owner) owner->rmComponent(this);
}

void SceneNode::draw()
{
    glPushMatrix();
    glMultMatrixf(glm::value_ptr(t));
    f(data);
    u32 size = (u32)children.size();
    for(u32 i = 0; i < size; i++) children[i]->draw();
    glPopMatrix();
}

SceneNode* SceneNode::getRoot()
{
    SceneNode* result = this;
    while(result->parent) result = result->parent;
    return result;
}

void SceneNode::drawScene()
{
    glPushMatrix();
    glMultMatrixf(glm::value_ptr(getInvGlobTF()));
    getRoot()->draw();
    glPopMatrix();
}

void SceneNode::orphan()
{
    for(std::vector<SceneNode*>::iterator i = parent->children.begin();
        i != parent->children.end(); i++)
    {
        if(*i == this)
            parent->children.erase(i);
    }
    parent = NULL;
}

bool SceneNode::sameTree(SceneNode* other)
{
    SceneNode* a = this;
    SceneNode* b = other;
    for(; !a->isRoot(); a = a->parent);
    for(; !b->isRoot(); b = b->parent);
    return a == b;
}

mat4 SceneNode::getGlobTF()
{
    mat4 a = t;
    SceneNode* n = parent;
    for(; n; n = n->parent) a = a * n->t;
    return glm::inverse(a);
}

mat4 SceneNode::getInvGlobTF()
{
    mat4 a = t;
    SceneNode* n = parent;
    for(; n; n = n->parent) a = a * n->t;
    return a;
}

void SceneNode::setGlobTF(mat4 tf)
{
    SceneNode* n = parent;
    mat4 a = n->t;
    while((n = n->parent)) a = n->t * a;
    t = glm::inverse(tf) * a;
}

