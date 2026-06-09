package br.edu.ifsp.carona.viagens.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    public static final String EXCHANGE = "carona.exchange";
    public static final String QUEUE_VIAGEM_CRIADA = "carona.viagem.criada";
    public static final String QUEUE_VIAGEM_PASSAGEIRO = "carona.viagem.passageiro";
    public static final String ROUTING_KEY_VIAGEM_CRIADA = "viagem.criada";
    public static final String ROUTING_KEY_VIAGEM_PASSAGEIRO = "viagem.passageiro";

    @Bean
    public TopicExchange exchange() {
        return new TopicExchange(EXCHANGE, true, false);
    }

    @Bean
    public Queue queueViagemCriada() {
        return new Queue(QUEUE_VIAGEM_CRIADA, true);
    }

    @Bean
    public Queue queueViagemPassageiro() {
        return new Queue(QUEUE_VIAGEM_PASSAGEIRO, true);
    }

    @Bean
    public Binding bindingViagemCriada(Queue queueViagemCriada, TopicExchange exchange) {
        return BindingBuilder.bind(queueViagemCriada).to(exchange).with(ROUTING_KEY_VIAGEM_CRIADA);
    }

    @Bean
    public Binding bindingViagemPassageiro(Queue queueViagemPassageiro, TopicExchange exchange) {
        return BindingBuilder.bind(queueViagemPassageiro).to(exchange).with(ROUTING_KEY_VIAGEM_PASSAGEIRO);
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
