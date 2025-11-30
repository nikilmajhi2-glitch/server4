-- ===========================================
-- PostgreSQL Schema for WhatsApp Gateway
-- Converted from MySQL → PostgreSQL
-- ===========================================

-- Drop tables if needed (safe run)
DROP TABLE IF EXISTS ai_chats, autoreplies, blasts, campaigns, contacts,
devices, message_histories, migrations, tags, users CASCADE;

-- =====================================================
-- ai_chats
-- =====================================================

CREATE TABLE ai_chats (
    id SERIAL PRIMARY KEY,
    sender_id VARCHAR(20) NOT NULL,
    number VARCHAR(20) NOT NULL,
    role VARCHAR(200) NOT NULL,
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- autoreplies
-- =====================================================

CREATE TABLE autoreplies (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    device_id VARCHAR(255) NOT NULL,

    keyword VARCHAR(255) NOT NULL,

    type_keyword TEXT CHECK (type_keyword IN ('Equal','Contain')) DEFAULT 'Equal',

    type TEXT CHECK (type IN ('text','button','image','template','list','media','vcard','location','sticker')),

    reply JSONB NOT NULL,

    status TEXT CHECK (status IN ('active','inactive')) DEFAULT 'active',

    reply_when TEXT CHECK (reply_when IN ('Group','Personal','All')) DEFAULT 'All',

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    is_quoted BOOLEAN DEFAULT FALSE,
    is_read BOOLEAN DEFAULT FALSE,
    is_typing BOOLEAN DEFAULT FALSE,

    delay INT DEFAULT 0
);

-- =====================================================
-- blasts
-- =====================================================

CREATE TABLE blasts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    sender VARCHAR(255) NOT NULL,
    campaign_id BIGINT NOT NULL,
    receiver VARCHAR(255) NOT NULL,
    message JSONB NOT NULL,

    type TEXT CHECK (type IN ('text','button','image','template','list','media','vcard','location','sticker')),

    status TEXT CHECK (status IN ('failed','success','pending')) NOT NULL,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- campaigns
-- =====================================================

CREATE TABLE campaigns (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    device_id BIGINT NOT NULL,
    phonebook_id BIGINT NOT NULL,
    delay INT DEFAULT 10,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,

    status TEXT CHECK (status IN ('waiting','processing','failed','completed','paused')) DEFAULT 'waiting',

    message JSONB NOT NULL,
    schedule TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- contacts
-- =====================================================

CREATE TABLE contacts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    name VARCHAR(255),
    number VARCHAR(255) NOT NULL,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    is_favorite INT DEFAULT 0
);

-- =====================================================
-- devices
-- =====================================================

CREATE TABLE devices (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    body VARCHAR(255) NOT NULL,
    webhook VARCHAR(255),

    status TEXT CHECK (status IN ('Connected','Disconnect')) DEFAULT 'Disconnect',

    profile_status VARCHAR(100),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    message_sent BIGINT DEFAULT 0,
    wh_read BOOLEAN DEFAULT FALSE,
    wh_typing BOOLEAN DEFAULT FALSE,
    delay INT DEFAULT 0,
    set_available BOOLEAN DEFAULT FALSE,

    gptkey VARCHAR(255),
    geminikey VARCHAR(255),
    reject_call BOOLEAN DEFAULT FALSE,

    gemini_status TEXT CHECK (gemini_status IN ('enabled','disabled')) DEFAULT 'disabled',
    gemini_model VARCHAR(50),
    gemini_api_key VARCHAR(200),
    gemini_instructions TEXT,

    transcription_status TEXT CHECK (transcription_status IN ('enabled','disabled')) DEFAULT 'disabled',
    transcription_model VARCHAR(50),
    huggingface_api_key VARCHAR(200),

    auto_status_save TEXT CHECK (auto_status_save IN ('enabled','disabled')) DEFAULT 'disabled',
    auto_status_forward TEXT CHECK (auto_status_forward IN ('enabled','disabled')) DEFAULT 'disabled',

    status_nudity_detection TEXT CHECK (status_nudity_detection IN ('enabled','disabled')) DEFAULT 'disabled',
    chat_nudity_detection TEXT CHECK (chat_nudity_detection IN ('enabled','disabled')) DEFAULT 'disabled'
);

-- =====================================================
-- message_histories
-- =====================================================

CREATE TABLE message_histories (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    device_id BIGINT NOT NULL,

    number VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,

    message TEXT NOT NULL,
    payload JSONB NOT NULL,

    status TEXT CHECK (status IN ('success','failed')) NOT NULL,

    send_by TEXT CHECK (send_by IN ('api','web')) NOT NULL,

    note VARCHAR(255),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- migrations
-- =====================================================

CREATE TABLE migrations (
    id SERIAL PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    batch INT NOT NULL
);

-- =====================================================
-- tags
-- =====================================================

CREATE TABLE tags (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- users
-- =====================================================

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,

    email_verified_at TIMESTAMP,

    password VARCHAR(255) NOT NULL,
    api_key VARCHAR(255) NOT NULL,
    chunk_blast INT NOT NULL,

    level TEXT CHECK (level IN ('admin','user')) DEFAULT 'user',

    status TEXT CHECK (status IN ('active','inactive')) DEFAULT 'active',

    limit_device INT DEFAULT 0,

    active_subscription TEXT CHECK (active_subscription IN ('inactive','active','lifetime','trial')) DEFAULT 'inactive',

    subscription_expired TIMESTAMP,
    remember_token VARCHAR(100),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- FOREIGN KEYS
-- =====================================================

ALTER TABLE autoreplies
ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE blasts
ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
ADD FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE;

ALTER TABLE campaigns
ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
ADD FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
ADD FOREIGN KEY (phonebook_id) REFERENCES tags(id) ON DELETE CASCADE;

ALTER TABLE contacts
ADD FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE;

ALTER TABLE devices
ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE message_histories
ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
ADD FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE;
