class Api::UploadFileController < ApplicationController
  def process_file
    if params.dig(:palestra, :arquivo).respond_to?(:read)
      file = params[:palestra][:arquivo]
      file_content = file.read.force_encoding('UTF-8')
      lines = file_content.split("\n")

      # Configuração das sessões
      sessao_manha = (9 * 60)..(12 * 60)
      sessao_tarde = (13 * 60)..(16 * 60)
      networking_start = 16 * 60

      # Inicialização das Vagas para as Tracks
      vaga_track_a_manha = true
      vaga_track_a_tarde = true
      vaga_track_b_manha = true
      vaga_track_b_tarde = true
      
      # Inicialização das Tracks
      track_a_manha = []
      track_a_tarde = []
      track_b_manha = []
      track_b_tarde = []

      # Inicialização dos tempos das sessões
      tempo_corrido_track_a_manha = sessao_manha.first
      tempo_corrido_track_a_tarde = sessao_tarde.first
      tempo_corrido_track_b_manha = sessao_manha.first
      tempo_corrido_track_b_tarde = sessao_tarde.first

      lines.each do |line|
        parts = line.split(' ')
        next if parts.empty?

        nome = parts[0..-2].join(' ')
        tempo = parts.last

        # Se o tempo não incluir "min", considera-se que seja "lightning" (5 minutos)
        if tempo !~ /\d+min/
          tempo = '5min'
        end

        minutos = tempo.to_i

        # Verifica se a palestra cabe na sessão da manhã na Track A
        if vaga_track_a_manha
          if tempo_corrido_track_a_manha + minutos <= sessao_manha.last 
            track_a_manha << "#{format_tempo(tempo_corrido_track_a_manha)} #{nome}"
            tempo_corrido_track_a_manha += minutos
          else
            track_a_manha << "12:00 Almoço"
            vaga_track_a_manha = false
          end
        end

        # Verifica se a palestra cabe na sessão da tarde na Track A
        if vaga_track_a_tarde && !vaga_track_a_manha
          if tempo_corrido_track_a_tarde + minutos < sessao_tarde.last
            track_a_tarde << "#{format_tempo(tempo_corrido_track_a_tarde)} #{nome}"
            tempo_corrido_track_a_tarde += minutos
          else
            track_a_tarde << "16:00 Evento de Networking"
            vaga_track_a_tarde = false
          end
        end

        # Verifica se a palestra cabe na sessão da manhã na Track B
        if vaga_track_b_manha && !vaga_track_a_tarde && !vaga_track_a_manha
          if tempo_corrido_track_b_manha + minutos <= sessao_manha.last
            track_b_manha << "#{format_tempo(tempo_corrido_track_b_manha)} #{nome}"
            tempo_corrido_track_b_manha += minutos
          else
            track_b_manha << "12:00 Almoço"
            vaga_track_b_manha = false
          end
        end

        # Verifica se a palestra cabe na sessão da tarde na Track B
        if vaga_track_b_tarde && !vaga_track_b_manha && !vaga_track_a_tarde && !vaga_track_a_manha
          if tempo_corrido_track_b_tarde + minutos < sessao_tarde.last
            track_b_tarde << "#{format_tempo(tempo_corrido_track_b_tarde)} #{nome}"
            tempo_corrido_track_b_tarde += minutos
          else
            track_b_tarde << "16:00 Evento de Networking"
            vaga_track_b_tarde = false
          end
        end
      end

      # Renderiza as Tracks A e B em formato JSON
      programacao_json = {
        "Track A Manhã": track_a_manha,
        "Track A Tarde": track_a_tarde,
        "Track B Manhã": track_b_manha,
        "Track B Tarde": track_b_tarde
      }

      render json: programacao_json
    else
      render json: { error: 'Nenhum arquivo enviado' }
    end
  end

  private

  def format_tempo(tempo_em_minutos)
    horas = tempo_em_minutos / 60
    minutos = tempo_em_minutos % 60
    format('%02d:%02d', horas, minutos)
  end
end
