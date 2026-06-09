package br.edu.ifsp.carona.usuarios.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    public static final String EXCHANGE = "carona.exchange";
    public static final String QUEUE_NOVO_USUARIO = "carona.usuario.novo";
    public static final String ROUTING_KEY_NOVO_USUARIO = "usuario.novo";

    @Bean
    public TopicExchange exchange() {
        return new TopicExchange(EXCHANGE);
    }

    @Bean
    public Queue queueNovoUsuario() {
        return new Queue(QUEUE_NOVO_USUARIO, true);
    }

    @Bean
    public Binding bindingNovoUsuario(Queue queueNovoUsuario, TopicExchange exchange) {
        return BindingBuilder.bind(queueNovoUsuario).to(exchange).with(ROUTING_KEY_NOVO_USUARIO);
    }

    @Bean
    public Jackson2JsonMessageConverter messageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory,
                                         Jackson2JsonMessageConverter messageConverter) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(messageConverter);
        return template;
    }
}
