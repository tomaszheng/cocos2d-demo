/****************************************************************************
 Copyright (c) 2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include <algorithm>
#include <spine/RealTimeAttachUtil.h>

USING_NS_CC;

namespace spine {
    const static std::string ATTACHED_ROOT_NAME = "ATTACHED_NODE_TREE";
    const static std::string ATTACHED_PRE_NAME = "ATTACHED_NODE:";

    void RealTimeAttachUtil::init(cocos2d::Node* skeletonNode, spine::Skeleton* skeleton)
    {
        _skeletonNode = skeletonNode;
        _skeleton = skeleton;
    }

    void RealTimeAttachUtil::releaseAttachedNodes() {
        for (auto* attachedNode : _attachedNodes) {
            attachedNode->release();
        }
        _attachedNodes.clear();
        _boneIndexToNode.clear();
    }

    void RealTimeAttachUtil::associateAttachedNode() {
        releaseAttachedNodes();
        
        auto* rootNode = _skeletonNode->getChildByName(ATTACHED_ROOT_NAME);
        if (!rootNode) return;

        _attachedRootNode = rootNode;
        
        auto& bones = _skeleton->getBones();
        for (std::size_t i = 0, n = bones.size(); i < n; i++) {
            auto* bone = bones[i];
            auto& boneData = bone->getData();
            auto boneName = ATTACHED_PRE_NAME;
            boneName.append(boneData.getName().buffer());
            
            Node* parentNode = nullptr;
            if (bone->getParent()) {
                auto const parentIndex = bone->getParent()->getData().getIndex();
                if (_attachedNodes[parentIndex]) {
                    parentNode = _attachedNodes[parentIndex]->boneNode;
                }
            } else {
                parentNode = rootNode;
            }
            
            if (parentNode) {
                auto* boneNode = parentNode->getChildByName(boneName);
                if (boneNode) {
                    buildBoneRelation(boneNode, bone, boneData.getIndex());
                }
            }
        }
    }

    void RealTimeAttachUtil::destroyAttachedNodes(std::string& boneName) {
        for (auto* attachedNode : _attachedNodes) {
            if (!attachedNode || !attachedNode->boneNode) continue;
            auto boneNodeName = attachedNode->boneNode->getName();
            auto const preLen = ATTACHED_PRE_NAME.size();
            auto delName = boneNodeName.substr(preLen, boneNodeName.size() - preLen);
            if (delName == boneName) {
                markAttachedNodeToRemove(attachedNode);
            }
        }

        rebuildAttachedNodes();
    }

    void RealTimeAttachUtil::markAttachedNodeToRemove(AttachedNode* rootNode) {
        auto* boneNode = rootNode->boneNode;
        boneNode->removeFromParent();
        rootNode->toRemove = true;
    }

    void RealTimeAttachUtil::rebuildAttachedNodes() {
        auto oldNodes = _attachedNodes;
        _attachedNodes = std::vector<AttachedNode*>();
        _boneIndexToNode.clear();

        for (auto* attachedNode : oldNodes) {
            if (!attachedNode) continue;
            if (attachedNode->toRemove || !attachedNode->boneNode) {
                attachedNode->release();
                continue;
            }
            _attachedNodes.push_back(attachedNode);
            _boneIndexToNode[attachedNode->boneIndex] = attachedNode->boneNode;
        }
    }

    void RealTimeAttachUtil::destroyAllAttachedNodes() {
        _attachedRootNode = nullptr;

        releaseAttachedNodes();

        auto* rootNode = _skeletonNode->getChildByName(ATTACHED_ROOT_NAME);
        if (rootNode) {
            rootNode->removeFromParent();
        }
    }

    cocos2d::Vector<Node*> RealTimeAttachUtil::generateAttachedNodes(std::string& boneName) {
        cocos2d::Vector<Node*> targetNodes;

        const auto* rootNode = prepareAttachNode();
        if (!rootNode) {
            return targetNodes;
        }

        std::vector<Bone*> targetBones;
        auto bones = _skeleton->getBones();
        for (int i = 0, n = bones.size(); i < n; i++) {
            auto* bone = bones[i];
            auto& boneData = bone->getData();
            if (strcmp(boneData.getName().buffer(), boneName.c_str()) == 0) {
                targetBones.push_back(bone);
            }
        }

        for (auto* bone : targetBones) {
            auto* targetNode = buildBoneTree(bone);
            targetNodes.pushBack(targetNode);
        }

        sortAttachedNodes();

        return targetNodes;
    }

    Node* RealTimeAttachUtil::buildBoneTree(Bone* bone) {
        if (!bone) return nullptr;

        auto& boneData = bone->getData();
        auto* boneNode = getNodeByBoneIndex(boneData.getIndex());
        if (boneNode) return boneNode;

        boneNode = buildBoneAttachedNode(bone, boneData.getIndex());
        auto* parentBoneNode = buildBoneTree(bone->getParent());
        if (!parentBoneNode) {
            parentBoneNode = _attachedRootNode;
        }

        parentBoneNode->addChild(boneNode);
        return boneNode;
    }

    Node* RealTimeAttachUtil::getNodeByBoneIndex(const int boneIndex) {
        const auto iterator = _boneIndexToNode.find(boneIndex);
        if (iterator == _boneIndexToNode.end()) {
            return nullptr;
        }
        auto* boneNode = _boneIndexToNode.at(boneIndex);
        return boneNode;
    }

    Node* RealTimeAttachUtil::buildBoneAttachedNode(Bone* bone, const int boneIndex) {
        const auto boneNodeName = ATTACHED_PRE_NAME + bone->getData().getName().buffer();
        auto* boneNode = Node::create();
        boneNode->setName(boneNodeName);
        buildBoneRelation(boneNode, bone, boneIndex);
        return boneNode;
    }

    void RealTimeAttachUtil::buildBoneRelation(Node* boneNode, Bone* bone, const int boneIndex) {
        // TODO -- limitNode(boneNode);

        auto* attachedNode = new AttachedNode(boneNode, bone, boneIndex);
        attachedNode->retain();

        _attachedNodes.push_back(attachedNode);
        _boneIndexToNode[boneIndex] = boneNode;
    }

    Node* RealTimeAttachUtil::prepareAttachNode() {
        if (!_skeleton) return nullptr;

        auto* rootNode = _skeletonNode->getChildByName(ATTACHED_ROOT_NAME);
        if (!rootNode)
        {
            rootNode = Node::create();
            rootNode->setName(ATTACHED_ROOT_NAME);
            _skeletonNode->addChild(rootNode);
        }
        _attachedRootNode = rootNode;
        return rootNode;
    }

    void RealTimeAttachUtil::sortAttachedNodes() {
        std::sort(_attachedNodes.begin(), _attachedNodes.end(), [](AttachedNode* a, AttachedNode* b) {
            return a->boneIndex < b->boneIndex;
        });
    }

    void RealTimeAttachUtil::syncAttachedNode() {
        if (!_attachedRootNode) return;

        static Mat4 boneMat;
        static Mat4 nodeWorldMat;
        
        const auto& rootMatrix = _skeletonNode->getNodeToParentTransform();
        _attachedRootNode->setNodeToParentTransform(rootMatrix);

        auto attachedNodesDirty = false;
        auto& bones = _skeleton->getBones();
        for (auto* attachedNode : _attachedNodes) {
            if (!attachedNode) {
                attachedNodesDirty = true;
                continue;
            }
            if (!attachedNode->boneNode) {
                attachedNodesDirty = true;
                attachedNode->toRemove = true;
                continue;
            }
            auto* const boneNode = attachedNode->boneNode;
            auto* const bone = bones[attachedNode->boneIndex];
            if (!bone) {
                attachedNodesDirty = true;
                boneNode->setVisible(false);
                boneNode->removeFromParent();
                attachedNode->toRemove = true;
                continue;
            }
            boneNode->setVisible(true);
            
            auto& mat = boneMat.m;
            mat[0] = bone->getA();
            mat[1] = bone->getC();
            mat[4] = bone->getB();
            mat[5] = bone->getD();
            mat[12] = bone->getX();
            mat[13] = bone->getY();
            Mat4::multiply(_attachedRootNode->getNodeToParentTransform(), boneMat, &nodeWorldMat);
            boneNode->setNodeToParentTransform(nodeWorldMat);

            boneNode->setPositionX(bone->getX());
            boneNode->setPositionY(bone->getY());
            boneNode->setScaleX(bone->getScaleX());
            boneNode->setScaleY(bone->getScaleY());
        }
        if (attachedNodesDirty) {
            rebuildAttachedNodes();
        }
    }
}
