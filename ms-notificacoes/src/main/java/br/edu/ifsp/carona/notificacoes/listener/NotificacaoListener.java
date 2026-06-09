package br.edu.ifsp.carona.notificacoes.listener;

import br.edu.ifsp.carona.notificacoes.config.RabbitMQConfig;
import br.edu.ifsp.carona.notificacoes.service.NotificacaoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificacaoListener {

    private final NotificacaoService notificacaoService;

    @RabbitListener(queues = RabbitMQConfig.QUEUE_NOVO_USUARIO)
    public void onNovoUsuario(Map<String, Object> dados) {
        log.info("Evento recebido - novo usuário: {}", dados);
        notificacaoService.processarNovoUsuario(dados);
    }

    @RabbitListener(queues = RabbitMQConfig.QUEUE_VIAGEM_CRIADA)
    public void onViagemCriada(Map<String, Object> dados) {
        log.info("Evento recebido - viagem criada: {}", dados);
        notificacaoService.processarViagemCriada(dados);
    }

    @RabbitListener(queues = RabbitMQConfig.QUEUE_VIAGEM_PASSAGEIRO)
    public void onPassageiroEntrou(Map<String, Object> dados) {
        log.info("Evento recebido - passageiro entrou: {}", dados);
        notificacaoService.processarPassageiroEntrou(dados);
    }
}
