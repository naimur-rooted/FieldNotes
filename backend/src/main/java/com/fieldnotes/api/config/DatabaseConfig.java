package com.fieldnotes.api.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;

@Configuration
public class DatabaseConfig {

    private static final Logger log = LoggerFactory.getLogger(DatabaseConfig.class);

    @Bean
    @Primary
    public DataSource dataSource(Environment env) {
        String rawUrl = env.getProperty("JDBC_DATABASE_URL");
        if (rawUrl == null || rawUrl.isBlank()) {
            rawUrl = env.getProperty("DATABASE_URL");
        }
        if (rawUrl == null || rawUrl.isBlank()) {
            rawUrl = env.getProperty("spring.datasource.url");
        }

        String username = env.getProperty("spring.datasource.username");
        String password = env.getProperty("spring.datasource.password");
        String driver = env.getProperty("spring.datasource.driver-class-name");

        if (rawUrl == null || rawUrl.isBlank()) {
            rawUrl = "jdbc:mysql://localhost:3306/fieldnotes?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        }

        rawUrl = rawUrl.trim();

        // Check if rawUrl contains credentials in URI format: ...://user:pass@host:port/db...
        if (rawUrl.contains("@")) {
            String working = rawUrl;
            if (working.startsWith("jdbc:")) {
                working = working.substring(5);
            }

            int slashSlash = working.indexOf("://");
            int atIndex = working.indexOf('@');

            if (slashSlash != -1 && atIndex > slashSlash) {
                String userInfo = working.substring(slashSlash + 3, atIndex);
                String hostAndPath = working.substring(atIndex + 1);

                if (userInfo.contains(":")) {
                    int colon = userInfo.indexOf(':');
                    username = userInfo.substring(0, colon);
                    password = userInfo.substring(colon + 1);
                } else {
                    username = userInfo;
                }

                String cleanJdbcUrl = "jdbc:postgresql://" + hostAndPath;
                if (!cleanJdbcUrl.contains("sslmode=")) {
                    cleanJdbcUrl += (cleanJdbcUrl.contains("?") ? "&" : "?") + "sslmode=require";
                }

                log.info("Auto-sanitized database URL from user:pass@host format to clean JDBC format.");
                HikariConfig config = new HikariConfig();
                config.setJdbcUrl(cleanJdbcUrl);
                config.setUsername(username);
                config.setPassword(password);
                config.setDriverClassName("org.postgresql.Driver");
                return new HikariDataSource(config);
            }
        }

        // Standard URL handling
        HikariConfig config = new HikariConfig();
        if (rawUrl.startsWith("postgres://")) {
            rawUrl = "jdbc:postgresql://" + rawUrl.substring("postgres://".length());
            driver = "org.postgresql.Driver";
        } else if (rawUrl.startsWith("postgresql://")) {
            rawUrl = "jdbc:postgresql://" + rawUrl.substring("postgresql://".length());
            driver = "org.postgresql.Driver";
        }

        config.setJdbcUrl(rawUrl);
        if (username != null && !username.isBlank()) config.setUsername(username);
        if (password != null && !password.isBlank()) config.setPassword(password);
        if (driver != null && !driver.isBlank()) config.setDriverClassName(driver);

        return new HikariDataSource(config);
    }
}
