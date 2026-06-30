-- 在线学习视频表
USE aicompanion;

DROP TABLE IF EXISTS learning_video;
CREATE TABLE learning_video (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  module_name VARCHAR(50)  NOT NULL COMMENT '所属模块：政治理论/言语理解/数量关系/判断推理/资料分析',
  title       VARCHAR(200) NOT NULL COMMENT '视频标题',
  description VARCHAR(500) DEFAULT '' COMMENT '视频描述',
  video_url   VARCHAR(500) NOT NULL COMMENT '视频访问路径，如 /uploads/videos/xxx.mp4',
  duration    INT          DEFAULT 0 COMMENT '视频时长（秒）',
  sort_order  INT          DEFAULT 0 COMMENT '排序权重，越小越靠前',
  deleted     TINYINT      DEFAULT 0 COMMENT '0-正常 1-已删除',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_module (module_name),
  INDEX idx_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='在线学习视频表';

-- 测试数据（video_url 为占位路径，上传真实视频后由后台管理更新）
INSERT INTO learning_video (module_name, title, description, video_url, duration, sort_order) VALUES
('政治理论', '政治理论 基础概述', '马克思主义基本原理概述', '/uploads/videos/zhengzhi_01.mp4', 0, 1),
('言语理解', '言语理解 逻辑填空', '逻辑填空解题技巧', '/uploads/videos/yanyu_01.mp4', 0, 1),
('数量关系', '数量关系 数字推理', '数字推理常考规律', '/uploads/videos/shuliang_01.mp4', 0, 1);
