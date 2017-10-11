require 'spec_helper'

module Pronto
  describe Flake8 do
    let(:flake8) { Flake8.new(patches) }
    let(:patches) { [] }
    describe '#flake8_executable' do
      subject(:flake8_executable) { flake8.flake8_executable }

      it 'is `flake8` by default' do
        expect(flake8_executable).to eql('flake8')
      end
    end

    describe '#cli_options' do
      around(:example) do |example|
        create_repository
        Dir.chdir(repository_dir) do
          example.run
        end
        delete_repository
      end

      context 'with custom cli_options' do
        before(:each) do
          add_to_index('.pronto_flake8.yml', "cli_options: '--test option'")
          create_commit
        end
      end
    end

    describe 'parsing' do
      it 'filtering python files' do
        files = %w[/Users/rabraham/requirements.txt /Users/rabraham/file.py]
        exp = flake8.filter_python_files(files)
        expect(exp).to eq(['/Users/rabraham/file.py'])
      end
      it 'extracts violation level' do
        expect(flake8.violation_level('W391 message2')).to eq('warning')
        expect(flake8.violation_level('E391 message2')).to eq('error')
      end

      it 'parses a linter output to a map' do
        executable_output = 'scripts/utils/cmdopts.py:115:26: E701 message1
        scripts/cmdopts.py:117:1: W391 message2'
        act = flake8.parse_output(executable_output)
        exp = [
          {
            file_path: 'scripts/utils/cmdopts.py',
            line_number: 115,
            column_number: 26,
            message: 'E701 message1',
            level: 'error'

          },
          {
            file_path: 'scripts/cmdopts.py',
            line_number: 117,
            column_number: 1,
            message: 'W391 message2',
            level: 'warning'
          }
        ]
        expect(act).to eq(exp)
      end
    end

    describe '#run' do
      around(:example) do |example|
        create_repository
        Dir.chdir(repository_dir) do
          example.run
        end
        delete_repository
      end

      let(:patches) { Pronto::Git::Repository.new(repository_dir).diff("master") }

      context 'patches are nil' do
        let(:patches) { nil }

        it 'returns an empty array' do
          expect(flake8.run).to eql([])
        end
      end

      context 'no patches' do
        let(:patches) { [] }

        it 'returns an empty array' do
          expect(flake8.run).to eql([])
        end
      end
      context 'with patch data' do
        before(:each) do
          function_use = <<-HEREDOC
          HEREDOC
          add_to_index('content.py', function_use)
          create_commit
        end
        context 'with error in changed file' do
          before(:each) do
            create_branch('staging', checkout: true)

            updated_function_def = <<-HEREDOC
            import sys
            HEREDOC

            add_to_index('content.py', updated_function_def)

            create_commit
          end

          it 'returns correct error message' do
            run_output = flake8.run
            expect(run_output.count).to eql(2)
            expect(run_output[0].msg).to eql('E999 IndentationError')
            expect(run_output[1].msg).to eql('E113 unexpected indentation')
          end
        end
      end
    end
  end
end
