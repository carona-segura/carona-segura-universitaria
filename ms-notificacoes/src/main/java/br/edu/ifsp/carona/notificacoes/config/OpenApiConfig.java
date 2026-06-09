package br.edu.ifsp.carona.notificacoes.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("MS Notificações - Carona Segura Universitária")
                        .description("Serviço de notificações — consome eventos do RabbitMQ e expõe histórico")
                        .version("1.0.0"));
    }
}
