package com.aicompanion.mapper;

import com.aicompanion.entity.AiChatMessage;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * AI对话记录Mapper接口
 */
@Mapper
public interface AiChatMessageMapper extends BaseMapper<AiChatMessage> {
}
