require 'gherkin_builder'
require 'unindent'

describe GherkinBuilder do
  include GherkinBuilder

  context 'a feature' do

    it 'generates the feature statement' do
      source = gherkin { feature }
      source.should == "Feature:\n"
    end

    context 'when a name is provided' do
      it 'includes the name in the feature statement' do
        source = gherkin do
          feature "A Feature\n"
        end
        source.should == "Feature: A Feature\n"
      end
    end

    context 'when a keyword is provided' do
      it 'uses the supplied keyword' do
        source = gherkin do
          feature "A Feature", keyword: "Business Need"
        end
        source.should == "Business Need: A Feature\n"
      end
    end

    context 'when a language is supplied' do
      it 'inserts a language statement' do
        source = gherkin do
          feature language: 'ru'
        end

        source.should == "# language: ru\nFeature:\n"
      end
    end

    context 'with a scenario' do
      it 'includes the scenario statement' do
        source = gherkin do
          feature "A Feature" do
            scenario
          end
        end

        source.should =~ /Scenario:/
      end

      context 'with a step' do
        it 'includes the step statement' do
          source = gherkin do
            feature "A Feature" do
              scenario do
                step 'passing'
              end
            end
          end

          source.should =~ /Given passing\Z/m
        end
      end
    end
  end

  it 'does' do
    source = gherkin do
      feature 'Fully featured', language: 'en' do
        background do
          step 'passing'
        end

        scenario do
          step 'passing'
        end

        scenario 'with doc string' do
          step 'passing'
          step 'failing', keyword: 'When' do
            doc_string <<-END
              I wish I was a little bit taller.

              I wish I was a baller.
            END
          end
        end

        scenario 'with a table...' do
          step 'passes:' do
            table do
              row 'name',   'age', 'location'
              row 'Janine', '43',  'Antarctica'
            end
          end
        end
      end
    end

    expected = <<-END
    # language: en
    Feature: Fully featured

      Background:
        Given passing

      Scenario:
        Given passing

      Scenario: with doc string
        Given passing
        When failing
          """
          I wish I was a little bit taller.
          
          I wish I was a baller.
          """

      Scenario: with a table...
        Given passes:
          | name   | age | location   |
          | Janine | 43  | Antarctica |
    END

    source.should == expected.unindent


  end
end
